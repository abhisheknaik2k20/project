import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/firebase_logic/webrtc/signaling.dart';

class MyHomePage extends StatefulWidget {
  final String userId;
  const MyHomePage({required this.userId, super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _initializeRenderers();
    _setupSignaling();
    _setupFCM();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  void _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _setupSignaling() {
    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });
  }

  void _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.data['type'] == 'call_offer') {
          _handleIncomingCall(message.data['roomId']);
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.data['type'] == 'call_offer') {
          _handleIncomingCall(message.data['roomId']);
        }
      });
    }
  }

  void _handleIncomingCall(String incomingRoomId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Incoming Call'),
        content: const Text('You have an incoming call. Would you like to answer?'),
        actions: [
          TextButton(
            child: const Text('Decline'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Accept'),
            onPressed: () {
              Navigator.of(context).pop();
              _joinRoom(incomingRoomId);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _createRoom() async {
    await signaling.openUserMedia(_localRenderer, _remoteRenderer);
    roomId = await signaling.createRoom(_remoteRenderer);
    setState(() {});

    // Send FCM notification to the other user
    await _sendCallNotification(widget.userId, roomId!);
  }

  Future<void> _joinRoom(String roomId) async {
    await signaling.openUserMedia(_localRenderer, _remoteRenderer);
    await signaling.joinRoom(roomId, _remoteRenderer);
  }

  Future<void> _sendCallNotification(String recipientId, String roomId) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'recipientId': recipientId,
      'type': 'call_offer',
      'roomId': roomId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WebRTC Call"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                  Expanded(child: RTCVideoView(_remoteRenderer)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _createRoom,
                  child: const Text("Start Call"),
                ),
                ElevatedButton(
                  onPressed: () {
                    signaling.hangUp(_localRenderer);
                  },
                  child: const Text("End Call"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }
}

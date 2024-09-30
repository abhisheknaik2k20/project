import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/firebase_logic/FCM/fcm.dart';
import 'package:project/firebase_logic/webrtc/signaling.dart';

class MyHomePage extends StatefulWidget {
  final String userId;
  final bool flag;
  const MyHomePage({required this.flag, required this.userId, super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String roomId = "Sameroom";
  late FirebaseMessaging _firebaseMessaging;
  late FCMSender _fcmSender;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _initializeRenderers();
    _setupSignaling();
    _setupFCM();
    if (widget.flag) {
      _createRoom();
    } else {
      _joinRoom(roomId);
    }
    _fcmSender = FCMSender();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
    _firebaseMessaging = FirebaseMessaging.instance;
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
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set({'fcmToken': token}, SetOptions(merge: true));

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

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    }
  }

  void _handleIncomingCall(String incomingRoomId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Incoming Call'),
        content:
            const Text('You have an incoming call. Would you like to answer?'),
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
    await signaling.createRoom(_remoteRenderer);
    setState(() {});
    await _sendCallNotification(widget.userId, "Sameroom");
  }

  Future<void> _joinRoom(String roomId) async {
    await signaling.openUserMedia(_localRenderer, _remoteRenderer);
    await signaling.joinRoom(roomId, _remoteRenderer);
  }

  Future<void> _sendCallNotification(String recipientId, String roomId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(recipientId)
        .get();

    String? recipientToken = userDoc.get('fcmToken');

    if (recipientToken != null) {
      await _fcmSender.sendNotification(
        fcmToken: recipientToken,
        title: 'Incoming Call',
        body: 'Tap to join the call',
        data: {
          'type': 'call_offer',
          'roomId': roomId,
        },
      );
    }
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

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  if (message.data['type'] == 'call_offer') {
    // You can't show UI when the app is in the background,
    // but you can process the data and show a notification
    // which the user can tap to open the app
  }
}

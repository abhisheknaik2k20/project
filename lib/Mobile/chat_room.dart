import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project/firebase_logic/FCM/fcm.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:pdfx/pdfx.dart';
import 'package:just_audio/just_audio.dart';

import '../firebase_logic/webRTC/webrtcengine.dart';

class ChatRoomScreen extends StatefulWidget {
  final Map<String, dynamic> userdata;

  const ChatRoomScreen({
    super.key,
    required this.userdata,
  });

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _messageController = TextEditingController();
  late String _currentUserId;
  late String _chatRoomId;

  // Define a color scheme
  final Color _primaryColor = Color(0xFF1E88E5); // A deep blue
  final Color _accentColor = Color(0xFFFFD54F); // A warm yellow
  final Color _backgroundColor = Color(0xFFF5F5F5); // A light grey
  final Color _textPrimaryColor = Color(0xFF212121); // Almost black
  final Color _textSecondaryColor = Color(0xFF757575); // A medium grey
  String _getChatRoomId(String userId1, String userId2) {
    return userId1.compareTo(userId2) < 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  final FCMSender _fcmSender = FCMSender();

  Future<void> _sendFCMNotification(String messageText) async {
    try {
      // Get the recipient's FCM token
      DocumentSnapshot recipientDoc = await _firestore
          .collection('users')
          .doc(widget.userdata['uid'])
          .get();
      String? recipientToken = recipientDoc.get('fcmToken');

      if (recipientToken != null) {
        await _fcmSender.sendNotification(
          fcmToken: recipientToken,
          title:
              "${_auth.currentUser?.displayName ?? 'Someone'} sent a message",
          body: messageText,
        );
      }
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }

  Future<void> _pickAndSendFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'pdf', 'mp3'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        String fileType = fileName.split('.').last.toLowerCase();

        String storagePath =
            'chat_files/$_chatRoomId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        UploadTask uploadTask = _storage.ref().child(storagePath).putFile(file);

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        await _firestore
            .collection('chat_rooms')
            .doc(_chatRoomId)
            .collection('messages')
            .add({
          'text': '',
          'senderId': _currentUserId,
          'timestamp': FieldValue.serverTimestamp(),
          'fileUrl': downloadUrl,
          'fileType': fileType,
          'fileName': fileName,
        });
      }
    } catch (e) {
      print('Error in _pickAndSendFile: $e');
      // You can show an error message to the user here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick or send file: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
    _chatRoomId = _getChatRoomId(_currentUserId, widget.userdata['uid']);
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // Send the message to Firestore
      await _firestore
          .collection('chat_rooms')
          .doc(_chatRoomId)
          .collection('messages')
          .add({
        'text': _messageController.text,
        'senderId': _currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
      // Send the notification
      await _sendFCMNotification(_messageController.text);
    }
  }

  Future<void> _sendPersistentFCMNotification(String messageText) async {
    try {
      // Get the recipient's FCM token
      DocumentSnapshot recipientDoc = await _firestore
          .collection('users')
          .doc(widget.userdata['uid'])
          .get();
      String? recipientToken = recipientDoc.get('fcmToken');

      if (recipientToken != null) {
        bool success = await _fcmSender.sendPersistentNotification(
          fcmToken: recipientToken,
          title:
              "${_auth.currentUser?.displayName ?? 'Someone'} sent a message",
          body: messageText,
          data: {
            'type': 'chat_message',
            'sender_id': _currentUserId,
            'chat_room_id': _chatRoomId,
          },
        );

        if (!success) {
          print('Failed to send persistent notification');
        }
      } else {
        print('Recipient FCM token not found');
      }
    } catch (e) {
      print('Error sending persistent FCM notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userdata['name'] ?? "None"),
        backgroundColor: _primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userdata['uid'])
                  .set(
                {"isCall": true},
                SetOptions(merge: true),
              );
              _sendPersistentFCMNotification("CALL INCOMMING....");
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AgoraRoom()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.video_call, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: Container(
        color: _backgroundColor,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chat_rooms')
                    .doc(_chatRoomId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                        child: CircularProgressIndicator(color: _primaryColor));
                  }
                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message =
                          messages[index].data() as Map<String, dynamic>;
                      final isMe = message['senderId'] == _currentUserId;
                      return _buildMessageBubble(message, isMe);
                    },
                  );
                },
              ),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.attach_file, color: _primaryColor),
            onPressed: _pickAndSendFile,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: _textPrimaryColor),
              decoration: InputDecoration(
                hintText: 'Send a message...',
                hintStyle: TextStyle(color: _textSecondaryColor),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: _primaryColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    if (message['fileUrl'] != null) {
      return _buildFileBubble(message, isMe);
    }
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isMe ? _primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message['text'],
          style: TextStyle(color: isMe ? Colors.white : _textPrimaryColor),
        ),
      ),
    );
  }

  Widget _buildFileBubble(Map<String, dynamic> message, bool isMe) {
    String fileType = message['fileType'];
    String fileName = message['fileName'];

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMe ? _primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white : _textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _openMediaViewer(message),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isMe ? _accentColor : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getFileIcon(fileType), color: _primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'View $fileType',
                      style: TextStyle(color: _textPrimaryColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'mp4':
        return Icons.video_library;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'mp3':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _openMediaViewer(Map<String, dynamic> message) {
    String fileType = message['fileType'];
    String fileUrl = message['fileUrl'];
    String fileName = message['fileName'];

    Widget viewer;
    switch (fileType) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        viewer = _ImageViewer(imageUrl: fileUrl);
        break;
      case 'mp4':
        viewer = _VideoViewer(videoUrl: fileUrl);
        break;
      case 'pdf':
        viewer = _PdfViewer(pdfUrl: fileUrl);
        break;
      case 'mp3':
        viewer = _AudioPlayer(audioUrl: fileUrl);
        break;
      default:
        viewer = const Center(child: Text('Unsupported file type'));
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text(fileName)),
        body: viewer,
      ),
    ));
  }
}

class _ImageViewer extends StatelessWidget {
  final String imageUrl;

  const _ImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}

class _VideoViewer extends StatefulWidget {
  final String videoUrl;

  const _VideoViewer({super.key, required this.videoUrl});

  @override
  _VideoViewerState createState() => _VideoViewerState();
}

class _VideoViewerState extends State<_VideoViewer> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(controller: _chewieController);
  }
}

class _PdfViewer extends StatelessWidget {
  final String pdfUrl;

  const _PdfViewer({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: http.readBytes(Uri.parse(pdfUrl)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final document = PdfDocument.openData(snapshot.data!);
            return SizedBox(
              height: 300,
              child: PdfView(
                controller: PdfController(document: document),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error loading PDF: ${snapshot.error}');
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

class _AudioPlayer extends StatefulWidget {
  final String audioUrl;

  const _AudioPlayer({super.key, required this.audioUrl});

  @override
  _AudioPlayerState createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<_AudioPlayer> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setUrl(widget.audioUrl);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _audioPlayer.play(),
          ),
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () => _audioPlayer.pause(),
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () => _audioPlayer.stop(),
          ),
        ],
      ),
    );
  }
}

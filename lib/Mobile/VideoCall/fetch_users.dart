import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/Mobile/Notifications/notifications.dart';
import 'package:project/firebase_logic/FCM/fcm.dart';
import 'package:project/firebase_logic/FCM/pushNotidata.dart';

class FetchUsersWEBRTC extends StatefulWidget {
  const FetchUsersWEBRTC({super.key});

  @override
  State<FetchUsersWEBRTC> createState() => _FetchUsersWEBRTCState();
}

class _FetchUsersWEBRTCState extends State<FetchUsersWEBRTC> {
  final NotificationService _notificationServices = NotificationService();
  late Future<String> _accessTokenFuture;

  @override
  void initState() {
    super.initState();
    _notificationServices.getUserPermission();
    _notificationServices.getDeviceToken().then((value) {
      print("Device FCM Token: $value");
    });
    _accessTokenFuture = PushNotificationService.getAccessToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Users'),
      ),
      body: FutureBuilder<String>(
        future: _accessTokenFuture,
        builder: (context, accessTokenSnapshot) {
          if (accessTokenSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (accessTokenSnapshot.hasError) {
            return Center(child: Text('Error: ${accessTokenSnapshot.error}'));
          }
//          final accessToken = accessTokenSnapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No users found'));
              }

              final currentUserId = FirebaseAuth.instance.currentUser?.uid;

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final userData =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  final userId = snapshot.data!.docs[index].id;
                  if (userId == currentUserId) {
                    return const SizedBox.shrink();
                  }
                  return ListTile(
                    leading: const CircleAvatar(),
                    title: Text(userData['name'] ?? 'Unknown User'),
                    subtitle: Text(userData['email'] ?? ''),
                    onTap: () async {
                      final fcmToken = userData['fcmToken'] as String?;
                      if (fcmToken != null) {
                        final result = await FCMSender().sendNotification(
                          fcmToken: userData['fcmToken'],
                          title: "New Message",
                          body: "You have a new message!",
                          data: {"type": "message", "sender": currentUserId},
                        );
                        if (result) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Notification sent successfully')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to send notification')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('User does not have a valid FCM token')),
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

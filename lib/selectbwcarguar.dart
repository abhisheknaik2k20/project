import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:googleapis/datamigration/v1.dart';
import 'package:project/Mobile/caretaker_list.dart';
import 'package:project/firebase_logic/FCM/fcm.dart';
import 'Mobile/guardian_list.dart';
class GuardianPage extends StatelessWidget {
  GuardianPage({super.key});
  late String lon = "";
  late String lat = "";

  Future _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      return Future.error('Location service are disabled!!');
    }
    LocationPermission lp = await Geolocator.checkPermission();
    if(lp == LocationPermission.denied){
      lp = await Geolocator.requestPermission();
      if(lp == LocationPermission.denied){
        return Future.error('Location service are disabled!!');
      }
    }
    if(lp == LocationPermission.deniedForever){
      return Future.error('Location service are forever disabled!!');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guardians'),
      ),
      backgroundColor: Colors.green,
      body: Expanded(
          child: SingleChildScrollView(
              child: Column(children: [
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return const GuardianListPage();
                          }));
                        },
                        onLongPress: () async {
                          // Get the current location
                          try {
                            var locationValue = await _getCurrentLocation();
                            lat = '${locationValue.latitude}';
                            lon = '${locationValue.longitude}';
                            print(lat);
                            print(lon);

                            // Fetch the documents from Firestore
                            QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                                .collection('users')
                                .get();

                            // Traverse through each document in the QuerySnapshot
                            for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
                              // Each documentSnapshot contains data as a map
                              Map<String, dynamic> documentData = documentSnapshot.data() as Map<String, dynamic>;

                              // Fetch the user document
                              DocumentSnapshot userDoc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(documentData['uid'])
                                  .get();

                              if (userDoc.exists && userDoc['fcmToken'] != null) {
                                bool notificationSent = await FCMSender().sendPersistentNotification(
                                  title: "DANGER",
                                  body: "DANGER",
                                  fcmToken: userDoc['fcmToken'],
                                );
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(documentData['uid'])
                                    .set({
                                  "inDanger": FirebaseAuth.instance.currentUser?.uid,
                                }, SetOptions(merge: true));
                                if (notificationSent) {
                                  print('Notification sent to ${userDoc['fcmToken']}');
                                } else {
                                  print('Failed to send notification to ${userDoc['fcmToken']}');
                                }
                              } else {
                                print('User document does not exist or FCM token is null');
                              }
                            }
                          } catch (e) {
                            print('Error: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/freinds.jpg',
                              height: 105,
                              width: 105,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "GUARDIANS",
                                      style: TextStyle(
                                        fontSize: 25,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      "View all Guardians",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ]),
                            )
                          ],
                        ))),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>CaretakerListPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/search.jpg',
                              height: 105,
                              width: 105,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "CARETAKERS",
                                      style: TextStyle(
                                        fontSize: 25,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      "View and Hire Caretakers and Specialists",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ]),
                            )
                          ],
                        ))),
              ]))),
    );
  }
}
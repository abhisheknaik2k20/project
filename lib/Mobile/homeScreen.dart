import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tilt/flutter_tilt.dart';

class Page12 extends StatefulWidget {
  const Page12({super.key});

  @override
  State<Page12> createState() => _Page1State();
}

class _Page1State extends State<Page12> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("ElderlyMate"),
          backgroundColor: Colors.green,
          actions: [
            IconButton(onPressed: (){}, icon: Icon(Icons.menu))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Tilt(
                  borderRadius: BorderRadius.circular(30),
                  tiltConfig: const TiltConfig(
                    angle: 30,
                    leaveDuration: Duration(seconds: 1),
                    leaveCurve: Curves.bounceOut,
                  ),
                  childLayout:  ChildLayout(
                    outer: [
                      Positioned(
                        child: TiltParallax(
                          size: Offset(40, 40),
                          child: Text(
                            'Hello, ${user!.displayName}',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  child: Container(
                    width: 350,
                    height: 200,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF80F0c7), Color(0xFF13a47a)],
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Tilt(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 160,
                        height: 250,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [Color(0xFF80F0c7), Color(0xFF13a47a)],
                          ),
                        ),
                        child: SizedBox(
                          width: 150,
                          child: const Text(
                            'Health Notifiaction: 0',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:Tilt(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 160,
                        height: 250,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [Color(0xFF80F0c7), Color(0xFF13a47a)],
                          ),
                        ),
                        child: SizedBox(
                          width: 160,
                          child: const Text(
                            'Previous Notifiaction: 1',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Tilt(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 160,
                        height: 250,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [Color(0xFF80F0c7), Color(0xFF13a47a)],
                          ),
                        ),
                        child: SizedBox(
                          width: 150,
                          child: const Text(
                            'App connected to Smart Watch',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Tilt(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 160,
                        height: 250,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [Color(0xFF80F0c7), Color(0xFF13a47a)],
                          ),
                        ),
                        child: SizedBox(
                          width: 150,
                          child: const Text(
                            'Current Health: Fine',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
    );
  }
}
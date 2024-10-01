import 'package:flutter/material.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:url_launcher/url_launcher.dart';

class supportPage extends StatelessWidget {
  const supportPage({super.key});

  Future<void> _openMap() async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=19,73',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Support Options')),
        body: Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 50, 0, 0),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.email),
            title: Text('Email'),
            subtitle: Text('elderlyMate@gmail.com'),
          ),

          // ListTile for Phone Number
          const ListTile(
            leading: Icon(Icons.phone),
            title: Text('Phone'),
            subtitle: Text('+9957374828'),
          ),

          // ListTile for Image
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTap: (){
                _openMap();
              },
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image.asset('assets/map.png'),
                  Text("Get our Offices", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 30),),
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}

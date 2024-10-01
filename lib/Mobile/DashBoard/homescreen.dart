import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/Mobile/DashBoard/nav_bar/navigation.dart';
import 'package:project/Mobile/calender/calendarPage.dart';
import 'package:project/selectbwcarguar.dart';

import '../../dataPage.dart';
import '../../firebase_logic/FCM/fcm.dart';
import '../Notifications/periodic_noti.dart';
import '../chat_room.dart';
import '../homeScreen.dart';

List<Widget> pages =  [
  Page12(),
  Page2(),
  Page3(),
  Page4(),
  Page1(),
];

class HomeScreen extends StatefulWidget {
  final bool isMenuOpen;
  const HomeScreen({super.key, required this.isMenuOpen});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    NotificationServicee().initNotification();
    NotificationServicee().showNotification(
        id: 0,
        title: "ElderlyMate",
        body: "Hello, We welcome you to our community",
        payLoad: "You we receive scheduled notification from now on"
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  pageChanged(int value) {
    setState(() {
      _selectedIndex = value;
    });
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AbsorbPointer(
          absorbing: widget.isMenuOpen,
          child: PageView(
            onPageChanged: (value) => pageChanged(value),
            controller: _pageController,
            children: pages,
          ),
        ),
        bottomNavigationBar:
            NavBar(selectedIndex: _selectedIndex, onItemTapped: onItemTapped));
  }
}

class Page1 extends StatelessWidget {
final FCMSender fcmSender = FCMSender();

Page1({Key? key}) : super(key: key);

@override
Widget build(BuildContext context) {
final currentUser = FirebaseAuth.instance.currentUser;

return Scaffold(
appBar: AppBar(
title: const Text('User Directory'),
elevation: 0,
backgroundColor: Theme.of(context).colorScheme.primary,
),
body: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance.collection('users').snapshots(),
builder: (context, snapshot) {
if (snapshot.hasError) {
return Center(child: Text('Error: ${snapshot.error}'));
}

if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(child: CircularProgressIndicator());
}

if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
return const Center(child: Text('No users found'));
}

var users = snapshot.data!.docs
    .where((doc) => doc.id != currentUser?.uid)
    .map((doc) => doc.data() as Map<String, dynamic>)
    .toList();

return ListView.builder(
  itemCount: users.length,
  itemBuilder: (context, index) {
    var userData = users[index];
    return UserCard(
        userData: userData,
        onTap: () {
          print("Tapped");
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                userdata: userData,
              )));
        });
  },
);
},
),
);
}
}
class UserCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onTap;

  const UserCard({Key? key, required this.userData, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
            leading: CircleAvatar(),
            title: Text(
              userData['name'] ?? 'No Name',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(userData['email'] ?? 'No Email'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onTap,
    ),);}
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
      body: CalendarPage(),
    );
  }
}

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: GuardianPage(),
    );
  }
}

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.pink,
      body: DataPage(),
    );
  }
}

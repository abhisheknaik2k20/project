import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project/Mobile/DashBoard/nav_bar/navigation.dart';
import 'package:project/notifications/periodic_noti.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../calender/calendarPage.dart';
import 'package:timezone/timezone.dart' as tz;

List<Widget> pages = [
  Page1(),
  CalendarPage(),
  const Page3(),
  const Page4(),
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
    NotificationService().initNotification();
    NotificationService().showNotification(
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

  late String lon = "";
  late String lat = "";

  Page1({super.key});

  @override
  Widget build(BuildContext context) {
    // DateTime scheduleTime = DateTime.now().add(Duration(seconds: 123123))
    return Scaffold(
      backgroundColor: Colors.red,
      body: Column(
          children: [
            ElevatedButton(onPressed: () {
              _getCurrentLocation().then((Value) {
                lat = '${Value.latitude}';
                lon = '${Value.longitude}';
                print(lat);
                print(lon);
              });
            }, child: Text("tap")),
            ElevatedButton(onPressed: () {
              _getCurrentLocation().then((Value) {
                lat = '${Value.latitude}';
                lon = '${Value.longitude}';
                print(lat);
                print(lon);
              });
              _openMap(lat, lon);
            }, child: Text("open")),
          ]),
    );
  }

  Future<void> _openMap(String lat, String lon) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<Position> _getCurrentLocation() async {
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
}

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
    );
  }
}

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
    );
  }
}

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.pink,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:project/Mobile/DashBoard/nav_bar/navigation.dart';

List<Widget> pages = const [
  Page1(),
  Page2(),
  Page3(),
  Page4(),
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
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.red,
    );
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

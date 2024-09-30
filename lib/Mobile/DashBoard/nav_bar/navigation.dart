import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  NavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final List gbuttons = [
    ["Home", Icons.home_rounded],
    ["Tasks", Icons.calendar_month_outlined],
    ["Search", Icons.search_rounded],
    ["Contacts", Icons.person_rounded],
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double navBarHeight = size.height * 0.08;
    final double iconSize = size.width * 0.06;
    final double horizontalPadding = size.width * 0.04;
    final double verticalPadding = size.height * 0.01;

    return Container(
      color: Colors.grey.shade900,
      height: navBarHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: GNav(
          selectedIndex: selectedIndex,
          backgroundColor: Colors.grey.shade900,
          gap: size.width * 0.02, // 2% of screen width
          activeColor: Colors.white,
          iconSize: iconSize,
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05, // 5% of screen width
            vertical: size.height * 0.015, // 1.5% of screen height
          ),
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: Colors.grey[800]!,
          color: Colors.grey[400],
          tabs: List.generate(gbuttons.length, (item) {
            return GButton(
              icon: gbuttons[item][1],
              text: gbuttons[item][0],
              onPressed: () => onItemTapped(item),
            );
          }),
        ),
      ),
    );
  }
}

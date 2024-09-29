import 'package:flutter/material.dart';
import 'dart:math' show pi;

import 'package:project/Mobile/DashBoard/drawer/drawer.dart';
import 'package:project/Mobile/DashBoard/homescreen.dart';

class BlackScreen extends StatelessWidget {
  const BlackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Drawer(
              menuScreen: EnhancedProfessionalSideDrawer(),
            ),
            MainScreen()
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _translateAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _translateAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.6, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: pi / 20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final delta = details.delta.dx / (MediaQuery.of(context).size.width * 0.5);
    _controller.value += delta;
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_controller.value > 0.5) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..translate(_translateAnimation.value.dx *
                  MediaQuery.of(context).size.width)
              ..rotateZ(_rotateAnimation.value)
              ..scale(_scaleAnimation.value),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30 * _controller.value),
              child: HomeScreen(
                isMenuOpen: _controller.value > 0.5,
              ),
            ),
          );
        },
      ),
    );
  }
}

class Drawer extends StatelessWidget {
  final Widget menuScreen;
  const Drawer({required this.menuScreen, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration:
          BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
      child: menuScreen,
    );
  }
}

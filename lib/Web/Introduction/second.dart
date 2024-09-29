import 'dart:math';

import 'package:flutter/material.dart';

class SecondWidget extends StatefulWidget {
  final Size size;
  final ScrollController scrollController;
  const SecondWidget(
      {required this.size, required this.scrollController, super.key});

  @override
  State<SecondWidget> createState() => _SecondWidgetState();
}

class _SecondWidgetState extends State<SecondWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _rotationAnimation = Tween<double>(
      begin: pi / 3,
      end: 0.0,
    ).animate(_animationController);
    _offsetAnimation = Tween<double>(
      begin: 0.0,
      end: widget.size.height * 1.15,
    ).animate(_animationController);

    widget.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final scrollPosition = widget.scrollController.position;
    final viewportDimension = scrollPosition.viewportDimension;
    final maxScrollExtent = scrollPosition.maxScrollExtent;

    if (scrollPosition.pixels >= maxScrollExtent) {
      ((scrollPosition.pixels - maxScrollExtent) / viewportDimension)
          .clamp(0.0, 1.0);
    } else {}

    final progress = (scrollPosition.pixels / maxScrollExtent).clamp(0.0, 1.0);
    _animationController.value = progress;
    setState(() {});
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size.height * 2,
      width: widget.size.width,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_rotationAnimation.value)
                  ..translate(0.0, _offsetAnimation.value, 0.0),
                child: Container(
                  width: widget.size.width * 0.8,
                  height: widget.size.height * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

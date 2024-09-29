import 'package:flutter/material.dart';

class AnimatedGradient extends StatefulWidget {
  final List<Color> color;
  const AnimatedGradient({required this.color, super.key});

  @override
  State<AnimatedGradient> createState() => AnimatedGradientState();
}

class AnimatedGradientState extends State<AnimatedGradient>
    with SingleTickerProviderStateMixin {
  late final Animation<Alignment> _topAlignment;
  late final Animation<Alignment> _bottomAlignment;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..repeat();
    _topAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(
          tween: Tween(begin: Alignment.topLeft, end: Alignment.topCenter),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.topCenter, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.topRight, end: Alignment.centerRight),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: Alignment.centerRight, end: Alignment.bottomRight),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: Alignment.bottomRight, end: Alignment.bottomCenter),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: Alignment.bottomCenter, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.bottomLeft, end: Alignment.centerLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.centerLeft, end: Alignment.topLeft),
          weight: 1),
    ]).animate(_controller);

    _bottomAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(
          tween:
              Tween(begin: Alignment.bottomRight, end: Alignment.bottomCenter),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: Alignment.bottomCenter, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.bottomLeft, end: Alignment.centerLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.centerLeft, end: Alignment.topLeft),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.topLeft, end: Alignment.topCenter),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.topCenter, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: Alignment.topRight, end: Alignment.centerRight),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: Alignment.centerRight, end: Alignment.bottomRight),
          weight: 1),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _topAlignment.value,
              end: _bottomAlignment.value,
              colors: widget.color,
            ),
          ),
        );
      },
    );
  }
}

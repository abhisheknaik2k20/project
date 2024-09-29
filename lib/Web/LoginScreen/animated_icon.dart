import 'dart:math';

import 'package:flutter/material.dart';

class EquidistantMovingIconsBackground extends StatefulWidget {
  final List<IconData> icons;
  final Color iconColor;
  final double iconSize;
  final int rows;
  final int columns;
  final Duration duration;
  final Offset direction;

  const EquidistantMovingIconsBackground({
    super.key,
    required this.icons,
    this.iconColor = Colors.black12,
    this.iconSize = 100,
    this.rows = 10,
    this.columns = 10,
    this.duration = const Duration(seconds: 20),
    this.direction = const Offset(1, 0),
  });

  @override
  State<EquidistantMovingIconsBackground> createState() =>
      _EquidistantMovingIconsBackgroundState();
}

class _EquidistantMovingIconsBackgroundState
    extends State<EquidistantMovingIconsBackground>
    with SingleTickerProviderStateMixin {
  late List<List<IconData>> _iconGrid;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initializeIconGrid();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  void _initializeIconGrid() {
    final random = Random();
    _iconGrid = List.generate(
        widget.rows,
        (_) => List.generate(widget.columns,
            (_) => widget.icons[random.nextInt(widget.icons.length)]));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: EquidistantIconsPainter(
                  iconGrid: _iconGrid,
                  progress: _controller.value,
                  iconColor: widget.iconColor,
                  iconSize: widget.iconSize,
                  direction: widget.direction,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class EquidistantIconsPainter extends CustomPainter {
  final List<List<IconData>> iconGrid;
  final double progress;
  final Color iconColor;
  final double iconSize;
  final Offset direction;

  EquidistantIconsPainter({
    required this.iconGrid,
    required this.progress,
    required this.iconColor,
    required this.iconSize,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final iconPainter = TextPainter(textDirection: TextDirection.ltr);
    final cellWidth = size.width / iconGrid[0].length;
    final cellHeight = size.height / iconGrid.length;

    for (int i = 0; i < iconGrid.length; i++) {
      for (int j = 0; j < iconGrid[i].length; j++) {
        final icon = iconGrid[i][j];

        final x =
            (j * cellWidth + progress * direction.dx * cellWidth) % size.width;
        final y = (i * cellHeight + progress * direction.dy * cellHeight) %
            size.height;

        iconPainter.text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: iconSize,
            fontFamily: icon.fontFamily,
            color: iconColor,
          ),
        );

        iconPainter.layout();
        iconPainter.paint(
          canvas,
          Offset(x - iconPainter.width / 2, y - iconPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant EquidistantIconsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

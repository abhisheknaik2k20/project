import 'package:flutter/material.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import 'package:project/colors/colors_scheme.dart';

class ParallaxInfoWidget extends StatefulWidget {
  final Size size;
  const ParallaxInfoWidget({required this.size, super.key});

  @override
  State<ParallaxInfoWidget> createState() => _ParallaxInfoWidgetState();
}

class _ParallaxInfoWidgetState extends State<ParallaxInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: SizedBox(
          height: widget.size.height * 0.8,
          width: widget.size.width * 0.9,
          child: Tilt(
            fps: 120,
            lightConfig: const LightConfig(disable: true),
            shadowConfig: const ShadowConfig(disable: true),
            tiltConfig: const TiltConfig(
              angle: 15,
              enableRevert: true,
              enableSensorRevert: true,
            ),
            child: Stack(
              children: [
                _buildParallaxImage(
                    top: 0.1,
                    left: 0.1,
                    size: 60,
                    offset: const Offset(-60, -60)),
                _buildParallaxImage(
                    top: 0.2,
                    right: 0.1,
                    size: 120,
                    offset: const Offset(80, 80)),
                _buildParallaxImage(
                    top: 0.2,
                    left: 0.4,
                    size: 200,
                    offset: const Offset(-100, -100)),
                _buildParallaxImage(
                    bottom: 0.1,
                    left: 0.15,
                    size: 90,
                    offset: const Offset(-90, -90)),
                _buildInfoCard(
                  top: 0.15,
                  left: 0.2,
                  right: 0.2,
                  title: "Feature 2",
                  description: "Innovative solution for improved productivity.",
                  offset: const Offset(30, 30),
                ),
                _buildParallaxImage(
                    top: 0.6,
                    right: 0.3,
                    size: 70,
                    offset: const Offset(70, 70)),
                _buildParallaxImage(
                    bottom: 0.2,
                    right: 0.15,
                    size: 180,
                    offset: const Offset(120, 120)),
                _buildParallaxImage(
                    bottom: 0.1,
                    left: 0.1,
                    size: 200,
                    offset: const Offset(110, 110)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParallaxImage({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Offset offset,
  }) {
    return Positioned(
      top: top != null ? widget.size.height * top : null,
      bottom: bottom != null ? widget.size.height * bottom : null,
      left: left != null ? widget.size.width * left : null,
      right: right != null ? widget.size.width * right : null,
      child: TiltParallax(
        size: offset,
        child: Image.asset(
          'assets/shape.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required String title,
    required String description,
    required Offset offset,
  }) {
    return Positioned(
      top: top != null ? widget.size.height * top : null,
      bottom: bottom != null ? widget.size.height * bottom : null,
      left: left != null ? widget.size.width * left : null,
      right: right != null ? widget.size.width * right : null,
      child: TiltParallax(
        size: offset,
        child: Container(
          width: 400,
          height: 400,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.honoluluBlue.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

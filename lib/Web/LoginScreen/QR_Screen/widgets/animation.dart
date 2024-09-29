import 'package:flutter/material.dart';
import 'package:project/Web/Introduction/widgets/animated_gradient.dart';
import 'package:project/colors/colors_scheme.dart';

class Decorations extends StatelessWidget {
  const Decorations({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Stack(
          children: [
            AnimatedGradient(
              color: [AppColors.pacificCyan, AppColors.federalBlue],
            ),
          ],
        ),
      ),
    );
  }
}

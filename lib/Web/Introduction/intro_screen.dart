import 'package:flutter/material.dart';
import 'package:project/Web/Introduction/first.dart';
import 'package:project/Web/Introduction/second.dart';
import 'package:project/Web/Introduction/widgets/animated_gradient.dart';
import 'package:project/Web/Introduction/widgets/app_bar.dart';
import 'package:project/colors/colors_scheme.dart';

class WebIntroScreen extends StatefulWidget {
  const WebIntroScreen({super.key});

  @override
  WebIntroScreenState createState() => WebIntroScreenState();
}

class WebIntroScreenState extends State<WebIntroScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;

  final GlobalKey<WebIntroScreenState> globalKey =
      GlobalKey<WebIntroScreenState>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const AnimatedGradient(
            color: [AppColors.pacificCyan, AppColors.lightCyan],
          ),
          Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: size.height * 0.1),
                  ),
                  SliverToBoxAdapter(
                    child: ParallaxInfoWidget(size: size),
                  ),
                  SliverToBoxAdapter(
                    child: SecondWidget(
                      size: size,
                      scrollController: _scrollController,
                    ),
                  ),
                ],
              ),
              CustomAppBar(size: size),
            ],
          ),
        ],
      ),
    );
  }
}

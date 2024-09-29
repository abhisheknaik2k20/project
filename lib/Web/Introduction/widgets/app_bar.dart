import 'package:flutter/material.dart';
import 'package:project/Web/LoginScreen/login_screen.dart';
import 'package:project/colors/colors_scheme.dart';

class CustomAppBar extends StatefulWidget {
  final Size size;
  const CustomAppBar({required this.size, super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _animation1 = Tween<double>(
      begin: 0,
      end: 150,
    ).animate(_animationController);
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.size.height * 0.03,
      left: 0,
      right: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth * 0.8;
          return Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                return Container(
                  width: maxWidth - _animation1.value,
                  padding: EdgeInsets.symmetric(
                    horizontal: maxWidth * 0.03,
                  ),
                  height: widget.size.height * 0.08,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bubble_chart,
                              color: Color(0xFF3A506B), size: 32),
                          SizedBox(width: 12),
                          Text(
                            'Nexus',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A506B),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildNavItem('Home', isActive: true),
                            _buildNavItem('About'),
                            _buildNavItem('Services'),
                            _buildNavItem('Login', isSpecial: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(String title,
      {bool isActive = false, bool isSpecial = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (isSpecial) return AppColors.pacificCyan;
              return Colors.transparent;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (isSpecial) return Colors.white;
              return const Color(0xFF3A506B);
            },
          ),
          elevation: WidgetStateProperty.all(0),
          padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          )),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return isSpecial
                    ? AppColors.pacificCyan
                    : const Color(0xFFE0FBFC).withOpacity(0.5);
              }
              return null;
            },
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSpecial ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

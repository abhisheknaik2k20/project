import 'package:flutter/material.dart';
import 'package:project/Web/LoginScreen/QR_Screen/widgets/animation.dart';
import 'package:project/colors/colors_scheme.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRCodeDisplayScreen extends StatefulWidget {
  final Function onTap;

  const QRCodeDisplayScreen({required this.onTap, super.key});

  @override
  State<QRCodeDisplayScreen> createState() => _QRCodeDisplayScreenState();
}

class _QRCodeDisplayScreenState extends State<QRCodeDisplayScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _animation;
  String text = "";
  String qrData = "";
  bool _showQR = false;
  bool _isProcessing = false;
  StreamSubscription<DocumentSnapshot>? _listener;
  User? _tempUser;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    );
    _controller.forward();
    _performAnonymousLogin();
  }

  Future<void> _performAnonymousLogin() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
      _tempUser = userCredential.user;
      setState(() {
        qrData = _tempUser!.uid;
        _showQR = true;
      });
      _startListening();
    } catch (e) {
      print("Error during anonymous login: $e");
      setState(() {
        _errorMessage = 'Failed to generate QR code. Please try again.';
      });
    }
  }

  void _startListening() {
    _listener = FirebaseFirestore.instance
        .collection('users')
        .doc(_tempUser!.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();
        if (data != null && data.containsKey('sharedBy')) {
          _processSharedCredentials(data['sharedBy']);
        }
      }
    });
  }

  Future<void> _processSharedCredentials(
      Map<String, dynamic> sharedData) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = '';
    });
    String email = sharedData['email'];
    String password = sharedData['password'];

    try {
      await _deleteTempAccount();
      print("Deleted account.....");
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      setState(() {
        _isProcessing = false;
        _errorMessage = "Yaaayyy!!!";
      });
    } catch (e) {
      print("Error during sign-in process: $e");
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Login failed. Please try again.';
      });
    }
  }

  Future<void> _deleteTempAccount() async {
    if (_tempUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_tempUser!.uid)
            .delete();
        await _tempUser!.delete();
      } catch (e) {
        print("Error deleting temp account: $e");
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _listener?.cancel();
    _deleteTempAccount();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 900,
      height: 700,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(_animation),
                    child: FadeTransition(
                      opacity: _animation,
                      child: const Text(
                        "Instant Access",
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: AppColors.federalBlue,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.5, 0),
                      end: Offset.zero,
                    ).animate(_animation),
                    child: FadeTransition(
                      opacity: _animation,
                      child: const Text(
                        "Scan the QR code with your mobile app for seamless login",
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.darkFontColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 220,
                              height: 220,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.honoluluBlue),
                                    ),
                                    SizedBox(height: 20),
                                    Text(
                                      "Processing login...",
                                      style: TextStyle(
                                        color: AppColors.darkFontColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _showQR
                              ? AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale:
                                          1.0 + 0.05 * _pulseController.value,
                                      child: Container(
                                        width: 220,
                                        height: 220,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.honoluluBlue
                                                  .withOpacity(0.2),
                                              blurRadius: 15,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: QrImageView(
                                          data: qrData,
                                          version: QrVersions.auto,
                                          size: 200.0,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const SizedBox(
                                  width: 220,
                                  height: 220,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.honoluluBlue),
                                    ),
                                  ),
                                ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage.isNotEmpty)
                    Center(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                  Center(
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(_animation),
                      child: FadeTransition(
                        opacity: _animation,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing
                              ? null
                              : () {
                                  _deleteTempAccount().then((_) {
                                    widget.onTap();
                                  });
                                },
                          icon: const Icon(Icons.arrow_back, size: 20),
                          label: const Text("Return to Login"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.lightFontColor,
                            backgroundColor: AppColors.honoluluBlue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Decorations()
        ],
      ),
    );
  }
}

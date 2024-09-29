import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? cameraController;

  bool isTorchOn = false;
  bool isCameraFront = false;
  bool isProcessing = false;
  String? successMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  void _initializeCamera() {
    cameraController = MobileScannerController();
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Scanner"),
        actions: [
          IconButton(
            icon: Icon(
              isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: isTorchOn
                  ? Colors.yellow
                  : const Color.fromRGBO(158, 158, 158, 1),
            ),
            onPressed: () {
              cameraController?.toggleTorch();
              setState(() {
                isTorchOn = !isTorchOn;
              });
            },
          ),
          IconButton(
            icon: Icon(
              isCameraFront ? Icons.camera_front : Icons.camera_rear,
            ),
            onPressed: () {
              cameraController?.switchCamera();
              setState(() {
                isCameraFront = !isCameraFront;
              });
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (successMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            Text(
              successMessage!,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetScanner,
              child: const Text('Scan Another'),
            ),
          ],
        ),
      );
    } else if (isProcessing) {
      return const Center(child: CircularProgressIndicator());
    } else if (cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return MobileScanner(
        controller: cameraController!,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            debugPrint('Barcode found! ${barcode.rawValue}');
            if (barcode.rawValue != null) {
              _processQRCode(barcode.rawValue!);
              break; // Process only the first detected barcode
            }
          }
        },
      );
    }
  }

  Future<void> _processQRCode(String qrData) async {
    if (isProcessing) return; // Prevent multiple simultaneous processing
    setState(() {
      isProcessing = true;
    });

    String scannedUid = qrData;

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently signed in.');
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Current user document not found in Firestore.');
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String? email = userData['email'];
      String? password = userData['password'];

      if (email == null || password == null) {
        throw Exception('Email or password not found in user document.');
      }

      await FirebaseFirestore.instance.collection('users').doc(scannedUid).set({
        'sharedBy': {
          'email': email,
          'password': password,
        }
      }, SetOptions(merge: true));

      setState(() {
        successMessage = 'Successfully appended data to scanned UID document.';
      });
    } catch (e) {
      print('Error processing QR code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      cameraController?.stop();
      setState(() {
        isProcessing = false;
      });
    }
  }

  void _resetScanner() {
    setState(() {
      successMessage = null;
      _initializeCamera();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }
}

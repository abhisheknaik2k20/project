// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<UserCredential?> loginEmailPass(
    BuildContext context, String email, String password) async {
  showDialog(
    context: context,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    // Perform login
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    // Generate FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null) {
      // Store FCM token in Firestore using set with merge
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'fcmToken': fcmToken}, SetOptions(merge: true));
    }

    // Set up FCM token refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'fcmToken': newToken}, SetOptions(merge: true));
    });

    Navigator.of(context).pop(); // Close loading dialog
    return userCredential;
  } on FirebaseAuthException catch (error) {
    Navigator.of(context).pop(); // Close loading dialog
    ScaffoldMessenger.of(context).showSnackBar(returnErrorSnackbar(error));
  } catch (error) {
    Navigator.of(context).pop(); // Close loading dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An unexpected error occurred: $error')),
    );
  }

  return null;
}

// Function to update FCM token
Future<void> updateFCMToken() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'fcmToken': token}, SetOptions(merge: true));
    }
  }
}

Future<UserCredential?> signupEmailPass(
    BuildContext context, String email, String password, String name) async {
  UserCredential? userCredential;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );
  try {
    userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await FirebaseAuth.instance.currentUser!.updateDisplayName(name);
    String uid = userCredential.user!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'password': password,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } on FirebaseAuthException catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(returnErrorSnackbar(error));
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An unexpected error occurred: $error')),
    );
  } finally {
    Navigator.of(context).pop();
  }
  return userCredential;
}

Future<UserCredential?> signupEmailPassMobile(BuildContext context,
    String email, String password, String name, String phone) async {
  UserCredential? userCredential;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );
  try {
    userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await FirebaseAuth.instance.currentUser!.updateDisplayName(name);
    String uid = userCredential.user!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'password': password,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } on FirebaseAuthException catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(returnErrorSnackbar(error));
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An unexpected error occurred: $error')),
    );
  } finally {
    Navigator.of(context).pop();
  }
  return userCredential;
}

Future<UserCredential?> signInWithGoogle(BuildContext context) async {
  GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
  try {
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithPopup(googleAuthProvider);

    return userCredential;
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(returnErrorSnackbar(e));
    return null;
  }
}

Future<UserCredential?> gitHubSignIn(BuildContext context) async {
  final githubAuthProvider = GithubAuthProvider();
  githubAuthProvider.addScope('read:user');
  githubAuthProvider.addScope('user:email');
  githubAuthProvider.setCustomParameters({
    'allow_signup': 'true',
  });
  try {
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithPopup(githubAuthProvider);
    return userCredential;
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(returnErrorSnackbar(e));
  }

  return null;
}

SnackBar returnErrorSnackbar(FirebaseAuthException error) {
  return SnackBar(
    content: Text(
      error.message ?? "Error during runtime",
      style: const TextStyle(color: Colors.white),
    ),
    duration: const Duration(seconds: 3),
    backgroundColor: Colors.red,
  );
}

SnackBar returnSuccessSnackbar(String text) {
  return SnackBar(
    content: Text(
      text,
      style: const TextStyle(color: Colors.white),
    ),
    duration: const Duration(seconds: 3),
    backgroundColor: Colors.green,
  );
}

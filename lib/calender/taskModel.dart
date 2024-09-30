import 'package:firebase_auth/firebase_auth.dart';

class Task {
  final String title;
  final String description;
  final DateTime date;

  Task({ required this.title, required this.description, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/firebase_logic/FCM/pushNotidata.dart';

class FCMSender {
  final String projectId = "project-d281b"; // Your Firebase project ID
  final String fcmEndpoint =
      'https://fcm.googleapis.com/v1/projects/{project_id}/messages:send';

  FCMSender();

  Future<bool> sendPersistentNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    String accessToken = await PushNotificationService.getAccessToken();
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final message = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'android': {
            'notification': {
              'sticky': true,
              'sound': 'iphone',
              'default_vibrate_timings': true,
              'notification_priority': 'PRIORITY_HIGH',
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'content-available': 1,
              },
            },
          },
          'data': data ?? {},
        },
      };

      final response = await http.post(
        Uri.parse(fcmEndpoint.replaceAll('{project_id}', projectId)),
        headers: headers,
        body: json.encode(message),
      );

      if (response.statusCode == 200) {
        print('Persistent FCM Notification sent successfully');
        return true;
      } else {
        print(
            'Persistent FCM Notification send failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending Persistent FCM Notification: $e');
      return false;
    }
  }

  Future<bool> sendPersistentNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    required String accessToken,
    Map<String, dynamic>? data,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final message = {
        'message': {
          'topic': topic,
          'notification': {
            'title': title,
            'body': body,
          },
          'android': {
            'notification': {
              'sticky': true,
              'default_sound': true,
              'default_vibrate_timings': true,
              'notification_priority': 'PRIORITY_HIGH',
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'content-available': 1,
              },
            },
          },
          'data': data ?? {},
        },
      };

      final response = await http.post(
        Uri.parse(fcmEndpoint.replaceAll('{project_id}', projectId)),
        headers: headers,
        body: json.encode(message),
      );

      if (response.statusCode == 200) {
        print('Persistent FCM Notification sent successfully to topic');
        return true;
      } else {
        print(
            'Persistent FCM Notification send to topic failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending Persistent FCM Notification to topic: $e');
      return false;
    }
  }

  Future<bool> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    String accessToken = await PushNotificationService.getAccessToken();
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final message = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data ?? {},
        },
      };

      final response = await http.post(
        Uri.parse(fcmEndpoint.replaceAll('{project_id}', projectId)),
        headers: headers,
        body: json.encode(message),
      );

      if (response.statusCode == 200) {
        print('FCM Notification sent successfully');
        return true;
      } else {
        print(
            'FCM Notification send failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending FCM Notification: $e');
      return false;
    }
  }

  Future<bool> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    required String accessToken,
    Map<String, dynamic>? data,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final message = {
        'message': {
          'topic': topic,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data ?? {},
        },
      };

      final response = await http.post(
        Uri.parse(fcmEndpoint.replaceAll('{project_id}', projectId)),
        headers: headers,
        body: json.encode(message),
      );

      if (response.statusCode == 200) {
        print('FCM Notification sent successfully to topic');
        return true;
      } else {
        print(
            'FCM Notification send to topic failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending FCM Notification to topic: $e');
      return false;
    }
  }
}

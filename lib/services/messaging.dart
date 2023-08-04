import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const key =
    'AAAAaLehtCo:APA91bGrrvhXkqM3F8W5cWFHlFTE0HVoUio8QIQtnwDey6cD55N66pRobT1x03Ti08jr79cFc8b4JyDhAiNcTUb0VdGsrb36keOx3Nz42JQwUKIaOv_W82HF1JbPTqTlHppKFyKJWKZu';

class MessagingService {
  void fcmSend(String? token) {
    try {
      http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$key',
        },
        body: jsonEncode({
          'to': token,
          'priority': 'high',
          'notification': {
            'title': '注文を送信しました',
            'body': '注文を送信しました',
          },
        }),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}

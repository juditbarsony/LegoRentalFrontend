import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String ngrokUrl = 'https://unread-mystify-scarecrow.ngrok-free.dev'; // ide az aktuális ngrok URL

  static String get baseUrl {
    if (kIsWeb) {
      return ngrokUrl;
    }

    if (Platform.isAndroid) {
      return ngrokUrl; // most ngrok-on megy minden
      // return 'http://10.0.2.2:8000'; // emulátorhoz
      // return 'http://127.0.0.1:8000'; // adb reverse-hez
    }

    return ngrokUrl;
  }

  static Uri uri(String path) {
    return Uri.parse('$baseUrl$path');
  }
}
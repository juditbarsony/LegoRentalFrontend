import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiService {
  // true = fizikai telefon USB + adb reverse
  // false = Android emulator
  static const bool usePhysicalPhone = true;

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    if (Platform.isAndroid) {
      return usePhysicalPhone
          ? 'http://127.0.0.1:8000'
          : 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  static Uri uri(String path) {
    return Uri.parse('$baseUrl$path');
  }
}
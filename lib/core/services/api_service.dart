import 'package:flutter/foundation.dart';

class ApiService {
  static final String baseUrl = kIsWeb
      ? 'http://localhost:8000'
      : 'http://10.0.2.2:8000';
}

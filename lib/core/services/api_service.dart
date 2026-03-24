import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final String baseUrl = kIsWeb
      ? 'http://localhost:8000'
      : 'http://10.0.2.2:8000';
}

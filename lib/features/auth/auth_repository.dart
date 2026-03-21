import 'dart:convert';
import 'package:http/http.dart' as http;

/// Ezt állítsd be a saját backend URL-edre:
/// Emulatorról általában: http://10.0.2.2:8000
/// Ha fizikai eszköz, akkor a géped lokális IP-je (pl. http://192.168.0.10:8000)
//const String baseUrl = 'http://192.168.1.67:8000/docs';
const String baseUrl = 'http://localhost:8000';

//debugPrint('URL: $baseUrl/auth/login');

class AuthRepository {
  final http.Client _client;

  AuthRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        // FastAPI OAuth2PasswordRequestForm mezőnevei:
        // username, password, scope, grant_type [web:102][web:105][web:110]
        'username': email,
        'password': password,
        'scope': '',
        'grant_type': 'password',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final accessToken = data['access_token'] as String?;
      if (accessToken == null) {
        throw Exception('Hiányzó access_token a válaszban');
      }
      return accessToken;
    } else {
      // próbáljuk kiolvasni a hibaüzenetet
      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final detail = errorData['detail']?.toString() ?? 'Ismeretlen hiba';
        throw Exception('Login hiba: $detail');
      } catch (_) {
        throw Exception('Login hiba: ${response.statusCode}');
      }
    }
  }

  Future<Map<String, dynamic>> getCurrentUser(String accessToken) async {
    final url = Uri.parse('$baseUrl/auth/users/me');

    final response = await _client.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data; // később csinálunk rá rendes modelt
    } else {
      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final detail = errorData['detail']?.toString() ?? 'Ismeretlen hiba';
        throw Exception('getCurrentUser hiba: $detail');
      } catch (_) {
        throw Exception('getCurrentUser hiba: ${response.statusCode}');
      }
    }
  }
}

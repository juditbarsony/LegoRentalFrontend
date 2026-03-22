import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  // Web/iOS esetén: static const String baseUrl = 'http://localhost:8000';

  // ── Token kezelés ──
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── AUTH ──

  static Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
        'grant_type': 'password',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'] as String;
      await saveToken(token);
      return token;
    }
    throw Exception('Bejelentkezés sikertelen: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String fullName,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'full_name': fullName,
        'password': password,
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Regisztráció sikertelen: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> getMe() async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/users/me'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Profil lekérés sikertelen: ${response.statusCode}');
  }

  // ── SETS ──

  static Future<List<Map<String, dynamic>>> fetchSets({
    String? keyword,
    String? setNum,
    String? location,
    String? state,
    int? themeId,
    bool public = true,
    bool includeUnavailable = false,
    String? availableFrom,
    String? availableTo,
    int limit = 20,
    int offset = 0,
  }) async {
    final headers = await _authHeaders();
    final params = <String, String>{
      'public': public.toString(),
      'include_unavailable': includeUnavailable.toString(),
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (setNum != null && setNum.isNotEmpty) 'set_num': setNum,
      if (location != null && location.isNotEmpty) 'location': location,
      if (state != null) 'state': state,
      if (themeId != null) 'theme_id': themeId.toString(),
      if (availableFrom != null) 'available_from': availableFrom,
      if (availableTo != null) 'available_to': availableTo,
    };

    final uri = Uri.parse('$baseUrl/sets').replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Setek betöltése sikertelen: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> fetchSetById(int setId) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/sets/$setId'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Set lekérés sikertelen: ${response.statusCode}');
  }

  // ── RENTALS ──

  static Future<Map<String, dynamic>> createRental({
    required int legoSetId,
    required String startDate,
    required String endDate,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/rentals'),
      headers: headers,
      body: jsonEncode({
        'lego_set_id': legoSetId,
        'start_date': startDate,
        'end_date': endDate,
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Bérlés létrehozása sikertelen: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> fetchRentals({
    bool? asRenter,
    bool? asOwner,
    String? statusFilter,
  }) async {
    final headers = await _authHeaders();
    final params = <String, String>{
      if (asRenter != null) 'as_renter': asRenter.toString(),
      if (asOwner != null) 'as_owner': asOwner.toString(),
      if (statusFilter != null) 'status_filter': statusFilter,
    };
    final uri =
        Uri.parse('$baseUrl/rentals').replace(queryParameters: params);
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Bérlések betöltése sikertelen: ${response.statusCode}');
  }
}

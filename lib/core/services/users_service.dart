import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lego_rental_frontend/core/models/user_model.dart';
import 'package:lego_rental_frontend/core/services/api_service.dart';




class UsersService {
  final String token;

  UsersService({required this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<UserModel>> getUsers() async {
    final response = await http.get(
      ApiService.uri('/users'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Nem sikerült lekérni a felhasználókat: ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
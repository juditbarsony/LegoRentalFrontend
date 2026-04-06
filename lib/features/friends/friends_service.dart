import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lego_rental_frontend/core/models/user_model.dart';
import 'package:lego_rental_frontend/core/services/api_service.dart';



class FriendsService {
  final String token;

  FriendsService({required this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<UserModel>> getFriends() async {
    final response = await http.get(
      ApiService.uri('/friends'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Nem sikerült lekérni a barátlistát: ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<UserModel> addFriend(int friendId) async {
    final response = await http.post(
      ApiService.uri('/friends/$friendId'),
      headers: _headers,
    );

    if (response.statusCode == 400) {
      throw Exception('Magadat nem jelölheted be.');
    }

    if (response.statusCode == 404) {
      throw Exception('A felhasználó nem található.');
    }

    if (response.statusCode == 409) {
      throw Exception('Ez a felhasználó már a barátaid között van.');
    }

    if (response.statusCode != 201) {
      throw Exception('Nem sikerült hozzáadni a barátot: ${response.body}');
    }

    return UserModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body)),
    );
  }

  Future<void> deleteFriend(int friendId) async {
    final response = await http.delete(
      ApiService.uri('/friends/$friendId'),
      headers: _headers,
    );

    if (response.statusCode == 404) {
      throw Exception('A barát kapcsolat nem található.');
    }

    if (response.statusCode != 200) {
      throw Exception('Nem sikerült törölni a barátot: ${response.body}');
    }
  }
}
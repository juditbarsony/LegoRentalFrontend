import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'lego_set.dart';
import 'package:lego_rental_frontend/features/auth/auth_providers.dart';

class SetsRepository {
  final http.Client _client;
  final String baseUrl;
  final Ref _ref;

  SetsRepository(
    this.baseUrl, {
    http.Client? client,
    required Ref ref,
  })  : _client = client ?? http.Client(),
        _ref = ref;

  Future<Map<String, String>> _authHeaders(String token) async {
  return {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}

Future<LegoSet> getSetById(int id, String token) async {
  final uri = Uri.parse('$baseUrl/sets/$id');
  final response = await _client.get(
    uri,
    headers: await _authHeaders(token),
  );

  if (response.statusCode == 200) {
    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    return LegoSet.fromJson(jsonMap);
  } else {
    throw Exception('Nem sikerült lekérni a készletet: ${response.statusCode}');
  }
}

Future<List<LegoSet>> loadSets({
  String? keyword,
  required String token,
}) async {
  final uri = Uri.parse('$baseUrl/sets/').replace(
    queryParameters: {
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
    },
  );

  final response = await _client.get(
    uri,
    headers: await _authHeaders(token),
  );

  if (response.statusCode == 200) {
    final jsonList = jsonDecode(response.body) as List<dynamic>;
    return jsonList
        .map((e) => LegoSet.fromJson(e as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Nem sikerült lekérni a készletlistát: ${response.statusCode}');
  }
}

}



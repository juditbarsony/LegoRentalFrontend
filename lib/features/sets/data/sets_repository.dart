import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lego_rental_frontend/core/models/lego_set_model.dart';
import 'package:lego_rental_frontend/core/services/api_service.dart';


class SetsRepository {
  final http.Client _client;

  SetsRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _authHeaders(String token) async {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<LegoSetModel> getSetById(int id, String token) async {
    final uri = Uri.parse('${ApiService.baseUrl}/sets/$id');
    final response = await _client.get(uri, headers: await _authHeaders(token));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return LegoSetModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Nem sikerült lekérni a készletet: ${response.statusCode}',
      );
    }
  }

  Future<List<LegoSetModel>> loadSets({
    String? keyword,
    int? themeId,
    required String token,
  }) async {
    final params = {
      'public': 'true',
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (themeId != null) 'theme_id': themeId.toString(),
    };
    final uri = Uri.parse(
      '${ApiService.baseUrl}/sets/',
    ).replace(queryParameters: params);
    final response = await _client.get(uri, headers: await _authHeaders(token));

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => LegoSetModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Nem sikerült lekérni a készletlistát: ${response.statusCode}',
      );
    }
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lego_rental_frontend/core/models/availability_model.dart';
import 'package:lego_rental_frontend/core/models/lego_set_model.dart';
import 'package:lego_rental_frontend/core/services/api_service.dart';

class SetAvailabilityModel {
  final int id;
  final int legoSetId;
  final String startDate;
  final String endDate;

  const SetAvailabilityModel({
    required this.id,
    required this.legoSetId,
    required this.startDate,
    required this.endDate,
  });

  factory SetAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return SetAvailabilityModel(
      id: json['id'] as int,
      legoSetId: json['lego_set_id'] as int,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
    );
  }
}

class SetsRepository {
  final http.Client _client;

  SetsRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _authHeaders(String token) async {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<LegoSetModel>> loadSets({
    String? keyword,
    int? themeId,
    String? state,
    String? location,
    double? maxPrice,
    required String token,
  }) async {
    final params = {
      'public': 'true',
      if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      if (themeId != null) 'theme_id': themeId.toString(),
      if (state != null) 'state': state,
      if (location != null) 'location': location,
    };

    final uri = Uri.parse(
      '${ApiService.baseUrl}/sets/',
    ).replace(queryParameters: params);

    final response = await _client.get(
      uri,
      headers: await _authHeaders(token),
    );

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      final sets = jsonList
          .map((e) => LegoSetModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (maxPrice != null) {
        return sets.where((s) => s.rentalPrice <= maxPrice).toList();
      }

      return sets;
    } else {
      throw Exception(
        'Nem sikerült lekérni a készletlistát: ${response.statusCode}',
      );
    }
  }

  Future<List<LegoSetModel>> loadMySets({
    required String token,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/sets/my');

    final response = await _client.get(
      uri,
      headers: await _authHeaders(token),
    );

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => LegoSetModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Nem sikerült lekérni a saját készleteket: ${response.statusCode}',
      );
    }
  }

  Future<LegoSetModel> getSetById(int id, String token) async {
    final uri = Uri.parse('${ApiService.baseUrl}/sets/$id');

    final response = await _client.get(
      uri,
      headers: await _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return LegoSetModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Nem sikerült lekérni a készlet részleteit: ${response.statusCode}',
      );
    }
  }

  Future<List<AvailabilityModel>> getAvailabilities(
    int setId,
    String token,
  ) async {
    final uri = Uri.parse('${ApiService.baseUrl}/sets/$setId/availabilities');

    final response = await _client.get(
      uri,
      headers: await _authHeaders(token),
    );

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => AvailabilityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Nem sikerült lekérni az elérhetőségeket: ${response.statusCode}',
      );
    }
  }

  Future<LegoSetModel> createSet({
    String? setNum,
    String? title,
    required String location,
    required double rentalPrice,
    required double deposit,
    required bool scanRequired,
    required bool isPublic,
    String? state,
    String? notes,
    List<String>? missingItems,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/sets/');

    final body = {
      if (setNum != null && setNum.trim().isNotEmpty) 'set_num': setNum.trim(),
      if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
      'location': location,
      'rental_price': rentalPrice,
      'deposit': deposit,
      'scan_required': scanRequired,
      'public': isPublic,
      if (state != null && state.isNotEmpty) 'state': state,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (missingItems != null) 'missing_items': missingItems,
    };

    final response = await _client.post(
      uri,
      headers: await _authHeaders(token),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return LegoSetModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Nem sikerült létrehozni a készletet: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> addAvailability({
    required int setId,
    required String startDate,
    required String endDate,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/sets/$setId/availabilities');

    final response = await _client.post(
      uri,
      headers: await _authHeaders(token),
      body: jsonEncode({
        'start_date': startDate,
        'end_date': endDate,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Nem sikerült hozzáadni az availability időszakot: ${response.statusCode} ${response.body}',
      );
    }
  }
}

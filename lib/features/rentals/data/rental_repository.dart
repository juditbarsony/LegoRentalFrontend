import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lego_rental_frontend/core/models/rental_model.dart';
import 'package:lego_rental_frontend/core/services/api_service.dart';

class RentalRepository {
  final http.Client _client;

  RentalRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _authHeaders(String token) async {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<RentalModel> createRental({
    required int legoSetId,
    required DateTime startDate,
    required DateTime endDate,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/rentals/');
    final body = jsonEncode({
      'lego_set_id': legoSetId,
      'start_date': startDate.toIso8601String().substring(0, 10),
      'end_date': endDate.toIso8601String().substring(0, 10),
    });

    final response = await _client.post(
      uri,
      headers: await _authHeaders(token),
      body: body,
    );

    if (response.statusCode == 201) {
      return RentalModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      final decoded = jsonDecode(response.body);
      final detail = decoded is Map<String, dynamic>
          ? decoded['detail'] ?? 'Ismeretlen hiba'
          : 'Ismeretlen hiba';
      throw Exception(detail);
    }
  }

  Future<List<RentalModel>> getMyRentals(String token) async {
    final baseUri = Uri.parse('${ApiService.baseUrl}/rentals/');
    final uri = baseUri.replace(
      queryParameters: {
        'as_renter': 'true',
      },
    );

    final response = await _client.get(
      uri,
      headers: await _authHeaders(token),
    );

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => RentalModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final decoded = jsonDecode(response.body);
      final detail = decoded is Map<String, dynamic>
          ? decoded['detail'] ?? 'Nem sikerült lekérni a bérléseket.'
          : 'Nem sikerült lekérni a bérléseket.';
      throw Exception(detail);
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lego_rental_frontend/core/services/api_service.dart';

class RentalRepository {
  final http.Client _client;

  RentalRepository({http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, String>> _authHeaders() async {
    final token = await ApiService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> createRental({
    required int legoSetId,
    required String startDate,
    required String endDate,
  }) async {
    final headers = await _authHeaders();
    final response = await _client.post(
      Uri.parse('${ApiService.baseUrl}/rentals'),
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

  Future<List<Map<String, dynamic>>> fetchRentals({
    bool? asRenter,
    bool? asOwner,
    String? statusFilter,
  }) async {
    final headers = await _authHeaders();
    final params = {
      if (asRenter != null) 'as_renter': asRenter.toString(),
      if (asOwner != null) 'as_owner': asOwner.toString(),
      if (statusFilter != null) 'status_filter': statusFilter,
    };
    final uri = Uri.parse('${ApiService.baseUrl}/rentals')
        .replace(queryParameters: params);
    final response = await _client.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Bérlések betöltése sikertelen: ${response.statusCode}');
  }
}

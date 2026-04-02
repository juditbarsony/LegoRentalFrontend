import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:lego_rental_frontend/core/models/scan_models.dart';
import 'package:lego_rental_frontend/core/services/api_service.dart';

class ScanRepository {
  final http.Client _client;

  ScanRepository({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
      };

  Future<ScanIdentifyResult> identifyPart({
    required Uint8List imageBytes,
    required String fileName,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/scan/identify');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_authHeaders(token))
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
      ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return ScanIdentifyResult.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Azonosítás sikertelen: ${response.statusCode}');
    }
  }

  Future<ScanSessionModel> createSession({
    required int rentalId,
    required int legoSetId,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/scan/session');
    final response = await _client.post(
      uri,
      headers: {
        ..._authHeaders(token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'rental_id': rentalId,
        'lego_set_id': legoSetId,
      }),
    );

    if (response.statusCode == 200) {
      return ScanSessionModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Session létrehozás sikertelen.');
    }
  }

  Future<ScanSessionModel> markItemIdentified({
    required int sessionId,
    required String partNum,
    required double confidence,
    required String token,
  }) async {
    final uri = Uri.parse(
        '${ApiService.baseUrl}/scan/session/$sessionId/item/$partNum?confidence=$confidence');
    final response = await _client.patch(
      uri,
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return ScanSessionModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Elem jelölés sikertelen.');
    }
  }

  Future<List<ScanSessionModel>> getSessionsForRental({
    required int rentalId,
    required String token,
  }) async {
    final uri =
        Uri.parse('${ApiService.baseUrl}/scan/rental/$rentalId');
    final response =
        await _client.get(uri, headers: _authHeaders(token));

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) =>
              ScanSessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Session lekérés sikertelen.');
    }
  }
}

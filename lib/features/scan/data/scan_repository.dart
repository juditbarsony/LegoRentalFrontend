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

  Map<String, String> _jsonHeaders(String token) => {
        ..._authHeaders(token),
        'Content-Type': 'application/json',
      };

  Future<List<ScanIdentifyResult>> identifyParts({
    required int sessionId,
    required Uint8List imageBytes,
    required String fileName,
    required String token,
  }) async {
    final uri = Uri.parse(
      '${ApiService.baseUrl}/scan/identify?session_id=$sessionId',
    );

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_authHeaders(token))
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final elements = data['elements'] as List<dynamic>;
      return elements
          .map((e) => ScanIdentifyResult.fromJson(e as Map<String, dynamic>))
          .toList();
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
      headers: _jsonHeaders(token),
      body: jsonEncode({
        'rental_id': rentalId,
        'lego_set_id': legoSetId,
      }),
    );

    if (response.statusCode == 200) {
      return ScanSessionModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Session létrehozás sikertelen: ${response.statusCode}');
    }
  }

  Future<ScanSessionModel?> getActiveSession({
    required int rentalId,
    required String token,
  }) async {
    final uri = Uri.parse(
      '${ApiService.baseUrl}/scan/rental/$rentalId/active-session',
    );

    final response = await _client.get(uri, headers: _authHeaders(token));

    if (response.statusCode == 200) {
      return ScanSessionModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    if (response.statusCode == 404) {
      return null;
    }

    throw Exception('Aktív session lekérés sikertelen: ${response.statusCode}');
  }

  Future<ScanSessionModel> getSession({
    required int sessionId,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/scan/session/$sessionId');

    final response = await _client.get(uri, headers: _authHeaders(token));

    if (response.statusCode == 200) {
      return ScanSessionModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Session lekérés sikertelen: ${response.statusCode}');
    }
  }

  Future<ScanSessionModel> markBatch({
    required int sessionId,
    required List<ScanIdentifyResult> elements,
    required String token,
  }) async {
    final uri = Uri.parse(
      '${ApiService.baseUrl}/scan/session/$sessionId/mark-batch',
    );

    final response = await _client.patch(
      uri,
      headers: _jsonHeaders(token),
      body: jsonEncode({
        'elements': elements
            .map((e) => {
                  'part_num': e.partNum,
                  'color_name': e.colorName,
                  'confidence': e.confidence,
                })
            .toList(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Mark batch failed: ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    print(
        'DEBUG markBatch response items: ${(decoded['items'] as List?)?.length}');
    print('DEBUG identified_count: ${decoded['identified_count']}');
    return ScanSessionModel.fromJson(decoded);
  }

  Future<ScanSessionModel> manualConfirmItem({
    required int sessionId,
    required int itemId,
    required String token,
  }) async {
    final uri = Uri.parse(
      '${ApiService.baseUrl}/scan/session/$sessionId/item/$itemId/confirm',
    );

    final response = await _client.patch(
      uri,
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return ScanSessionModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Manuális jelölés sikertelen: ${response.statusCode}');
    }
  }

  Future<ScanSessionModel> resetProgress({
    required int sessionId,
    required String token,
  }) async {
    final uri = Uri.parse(
      '${ApiService.baseUrl}/scan/session/$sessionId/reset',
    );

    final response = await _client.patch(
      uri,
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return ScanSessionModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Progress reset sikertelen: ${response.statusCode}');
    }
  }

  Future<ScanSessionModel> finishSession({
    required int sessionId,
    required String token,
  }) async {
    final uri = Uri.parse(
      '${ApiService.baseUrl}/scan/session/$sessionId/finish',
    );

    final response = await _client.patch(
      uri,
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      return ScanSessionModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Session lezárás sikertelen: ${response.statusCode}');
    }
  }

  Future<List<ScanSessionModel>> getSessionsForRental({
    required int rentalId,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/scan/rental/$rentalId');

    final response = await _client.get(uri, headers: _authHeaders(token));

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => ScanSessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Session lekérés sikertelen: ${response.statusCode}');
    }
  }

  Future<List<ScanSessionModel>> getMyReports({required String token}) async {
    final uri = Uri.parse('${ApiService.baseUrl}/scan/my-reports');
    final response = await _client.get(uri, headers: _authHeaders(token));

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => ScanSessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Reports betöltés sikertelen: ${response.statusCode}');
  }
}

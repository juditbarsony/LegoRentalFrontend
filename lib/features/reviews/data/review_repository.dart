import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lego_rental_frontend/core/models/review_model.dart';
import 'package:lego_rental_frontend/core/services/api_service.dart';

class ReviewRepository {
  final String baseUrl = ApiService.baseUrl; // vagy a tiéd

  Future<List<ReviewModel>> getReviewsForUser({
    required int userId,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reviews/user/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load reviews.');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => ReviewModel.fromJson(e)).toList();
  }
}
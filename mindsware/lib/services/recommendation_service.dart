import 'dart:convert';
import 'package:http/http.dart' as http;

class RecommendationService {
  final String apiUrl;

  RecommendationService({this.apiUrl = "http://192.168.1.159:8080"});

  Future<Map<String, dynamic>> getRecommendation({
    required int bsmas,
    required int screentime,
  }) async {
    final url = Uri.parse("$apiUrl/predict");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "bsmas": bsmas,
        "screentime": screentime,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Sunucudan veri alınamadı. Kod: ${response.statusCode}");
    }
  }
}

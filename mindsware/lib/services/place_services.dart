import 'dart:convert';
import 'package:http/http.dart' as http;

class Place {
  final String name;
  final String address;
  final double? rating;
  final String? placeId;
  final bool isOpen;
  final String? photoReference;

  Place({
    required this.name,
    required this.address,
    this.rating,
    this.placeId,
    this.isOpen = true,
    this.photoReference,
  });

  factory Place.fromProxy(Map<String, dynamic> j) {
    return Place(
      name: j['name'] ?? 'İsimsiz Mekan',
      address: j['vicinity'] ?? 'Adres yok',
      rating: (j['rating'] is num) ? (j['rating'] as num).toDouble() : null,
      placeId: j['place_id'],
      isOpen: j['open_now'] ?? true,
      photoReference: j['photo_reference'],
    );
  }
}

class PlaceService {
  /// LOKAL GELİŞTİRME:
  /// - Android emülatör: "http://10.0.2.2:8000"
  /// - Fiziksel cihaz (aynı Wi-Fi): "http://192.168.x.x:8000"
  /// PROD: "https://api.senin-domainin.com"
  final String baseUrl;
  PlaceService({required this.baseUrl});

  Future<List<Place>> getNearbyPlaces({
    required double lat,
    required double lng,
    String type = "park",
    int radius = 2000,
    String language = "tr",
  }) async {
    final uri = Uri.parse(
      "$baseUrl/places/nearby?lat=$lat&lng=$lng&type=$type&radius=$radius&language=$language",
    );

    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception("Proxy hata: ${res.statusCode} ${res.body}");
    }
    final data = jsonDecode(res.body);
    final status = data['status'] ?? 'UNKNOWN_ERROR';
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw Exception("Places hata: $status");
    }
    final List list = data['results'] ?? [];
    return list.map((e) => Place.fromProxy(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final uri = Uri.parse("$baseUrl/places/details?place_id=$placeId&language=tr");
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception("Proxy hata: ${res.statusCode} ${res.body}");
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  String? getPhotoUrl(String? photoReference, {int maxWidth = 600}) {
    if (photoReference == null || photoReference.isEmpty) return null;
    return "$baseUrl/places/photo?photo_reference=$photoReference&maxwidth=$maxWidth";
  }
}

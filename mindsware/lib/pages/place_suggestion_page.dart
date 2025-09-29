import 'dart:convert';
import 'package:flutter/foundation.dart' show kReleaseMode, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// NOTE: Aşağıdaki Place ve PlaceService'in senin proxy'li sürüm olduğundan emin ol.
// PlaceService, /places/nearby, /places/details, /places/photo endpoint'lerini çağırmalı.
import 'package:mindsware/services/place_services.dart';

class PlaceSuggestionPage extends StatefulWidget {
  const PlaceSuggestionPage({super.key});

  @override
  _PlaceSuggestionPageState createState() => _PlaceSuggestionPageState();
}


class _PlaceSuggestionPageState extends State<PlaceSuggestionPage> {
  // ---- UI state ----
  List<Place> places = [];
  bool isLoading = false;
  String selectedType = 'park';
  String errorMessage = '';

  // ---- Service ----
  late final PlaceService _placeService;
  Position? currentPosition;

  // ---------- Helpers: health ping & auto base url ----------
  Future<bool> _isAlive(String base, {Duration timeout = const Duration(seconds: 70)}) async {
    try {
      final res = await http.get(Uri.parse('$base/health')).timeout(timeout);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body is Map && body['ok'] == true;
      }
    } catch (_) {}
    return false;
  }

  Future<String> _autoResolveBaseUrl() async {
    if (kReleaseMode) {
      // PROD: kendi domain'in (HTTPS önerilir)
      return 'https://api.senin-domainin.com';
    }

    // DEBUG adayları (sırayla denenecek)
    final candidates = <String>[
      'http://10.0.2.2:8000',  // Android emülatör → host makine
      'http://127.0.0.1:8000', // ADB reverse / iOS simulator / desktop
      'http://localhost:8000',
      // tünel kullanıyorsan buraya ekle:
      // 'https://xxxx-xx-xx-xx-xx.ngrok-free.app',
    ];

    if (defaultTargetPlatform != TargetPlatform.android) {
      // Android dışı platformlarda 10.0.2.2 en sona
      candidates
        ..remove('http://10.0.2.2:8000')
        ..add('http://10.0.2.2:8000');
    }

    for (final base in candidates) {
      if (await _isAlive(base)) return base;
    }

    // Hiçbiri çalışmazsa son çare prod URL
    return 'https://api.senin-domainin.com';
  }

  @override
  void initState() {
    super.initState();
    _initServiceAndFetch();
  }

  Future<void> _initServiceAndFetch() async {
    final base = await _autoResolveBaseUrl();
    _placeService = PlaceService(baseUrl: base);
    if (!mounted) return;
    await fetchPlaces();
  }

  // ---------- Location permission & fetch ----------
  Future<bool> _handleLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => errorMessage = 'Konum servisi kapalı. Ayarlar > Konum’dan servisi açın.');
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => errorMessage = 'Konum izni reddedildi. Lütfen uygulamaya konum izni verin.');
          return false;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => errorMessage =
            'Konum izni kalıcı olarak reddedildi. Ayarlar > Uygulamalar > MindsWare > İzinler’den konum iznini açın.');
        return false;
      }
      return true;
    } catch (e) {
      setState(() => errorMessage = 'Konum izni kontrol edilirken hata: $e');
      return false;
    }
  }

  Future<void> fetchPlaces() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        setState(() => isLoading = false);
        return;
      }

      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final results = await _placeService.getNearbyPlaces(
        lat: currentPosition!.latitude,
        lng: currentPosition!.longitude,
        type: selectedType,
        radius: 2000,
        language: 'tr',
      );

      setState(() {
        places = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        if (e.toString().contains('Connection refused') ||
            e.toString().contains('Failed host lookup') ||
            e.toString().contains('Connection timed out')) {
          errorMessage =
              'Sunucuya bağlanılamadı. Emülatördeysen baseUrl= http://10.0.2.2:8000, '
              'gerçek cihazdaysan bilgisayarının IP’sini veya tünel adresini kullan.';
        } else {
          errorMessage = 'Hata oluştu: $e';
        }
      });
    }
  }

  // ---------- UI ----------
  // Mekan türleri haritası
  final Map<String, String> placeTypes = const {
    'park': 'Park',
    'library': 'Kütüphane',
    'cafe': 'Kafe',
    'restaurant': 'Restoran',
    'gym': 'Spor Salonu',
    'hospital': 'Hastane',
    'pharmacy': 'Eczane',
    'shopping_mall': 'Alışveriş Merkezi',
    'bank': 'Banka',
    'gas_station': 'Benzin İstasyonu',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mekan Önerileri'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : fetchPlaces,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: Column(
        children: [
          // Mekan türü seçici
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: selectedType,
              decoration: InputDecoration(
                labelText: 'Mekan Türü Seç',
                prefixIcon: Icon(_getIconForType(selectedType)),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: placeTypes.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(_getIconForType(entry.key), size: 20),
                      const SizedBox(width: 8),
                      Text(entry.value),
                    ],
                  ),
                );
              }).toList(),
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => selectedType = value);
                        fetchPlaces();
                      }
                    },
            ),
          ),

          // Hata mesajı
          if (errorMessage.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),

          // İçerik alanı
          if (isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Mekanlar aranıyor...'),
                    SizedBox(height: 8),
                    Text(
                      'Bu işlem birkaç saniye sürebilir',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else if (places.isEmpty && errorMessage.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      "Yakında ${placeTypes[selectedType]?.toLowerCase()} bulunamadı",
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Farklı bir mekan türü seçmeyi deneyin",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: fetchPlaces,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchPlaces,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Icon(_getIconForType(selectedType),
                              color: Colors.white, size: 24),
                        ),
                        title: Text(
                          place.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    place.address,
                                    style: TextStyle(color: Colors.grey.shade700),
                                  ),
                                ),
                              ],
                            ),
                            if (place.rating != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${place.rating!.toStringAsFixed(1)} ⭐',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Gerçek dünya ile bağ kurmak için buraya gitmeyi düşünebilirsin 🌟",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${place.name} seçildi'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                          // TODO: Detay sayfasına yönlendirme eklenebilir.
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'park':
        return Icons.park;
      case 'library':
        return Icons.library_books;
      case 'cafe':
        return Icons.local_cafe;
      case 'restaurant':
        return Icons.restaurant;
      case 'gym':
        return Icons.fitness_center;
      case 'hospital':
        return Icons.local_hospital;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'shopping_mall':
        return Icons.shopping_cart;
      case 'bank':
        return Icons.account_balance;
      case 'gas_station':
        return Icons.local_gas_station;
      default:
        return Icons.place;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key, required List usageStats});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  static const platform = MethodChannel('com.example.usage_stats');
  List<AppUsage> _apps = [];
  Map<String, dynamic> _usageData = {};
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  List<double> _hourlyData = List.filled(24, 0.0);
  Map<String, Duration> _categoryUsage = {};
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUsageStats();
  }

  Future<void> _requestUsagePermission() async {
    try {
      await platform.invokeMethod('requestUsagePermission');
      // İzin verildikten sonra verileri tekrar çek
      await Future.delayed(const Duration(seconds: 1));
      _fetchUsageStats();
    } on PlatformException catch (e) {
      debugPrint('İzin ekranı açılamadı: $e');
      setState(() {
        _errorMessage = 'İzin ekranı açılamadı: ${e.message}';
      });
    }
  }

  Future<void> _fetchUsageStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final stats = await platform.invokeMethod('getUsageStats', {
        'date': _selectedDate.millisecondsSinceEpoch,
      });
      
      if (stats != null && stats is Map) {
        _parseUsageStats(stats);
      } 
    } on PlatformException catch (e) {
      debugPrint('Kullanım verileri alınamadı: $e');
      setState(() {
        _errorMessage = 'Hata: ${e.message}';
      });
      
      // İzin yoksa izin ekranını aç
      if (e.code == 'PERMISSION_REQUIRED') {
        _showPermissionDialog();
      } 
    } catch (e) {
      debugPrint('Beklenmeyen hata: $e');
      setState(() {
        _errorMessage = 'Beklenmeyen hata: $e';
      });
      
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title: const Text(
            'İzin Gerekli',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Ekran süresi verilerine erişmek için kullanım erişimi izni gerekiyor.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestUsagePermission();
              },
              child: const Text('İzin Ver', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }


  void _parseUsageStats(Map<dynamic, dynamic> stats) {
    List<AppUsage> apps = [];
    Map<String, Duration> categoryUsage = {};
    List<double> hourlyData = List.filled(24, 0.0);
    
    // Uygulama verilerini parse et
    if (stats['apps'] != null && stats['apps'] is List) {
      for (var appData in stats['apps']) {
        if (appData is Map) {
          final timeInForeground = appData['timeInForeground'] ?? 0;
          final totalTime = Duration(milliseconds: timeInForeground is int ? timeInForeground : 0);
          
          // Sadece kullanım süresi 0'dan büyük olan uygulamaları ekle
          if (totalTime.inSeconds > 0) {
            final appUsage = AppUsage(
              name: appData['name']?.toString() ?? 'Bilinmeyen Uygulama',
              packageName: appData['packageName']?.toString() ?? '',
              usage: _formatDuration(totalTime),
              totalTime: totalTime,
              category: _getCategoryForApp(appData['packageName']?.toString() ?? ''),
            );
            apps.add(appUsage);
          }
        }
      }
    }
    
    // Uygulamaları kullanım süresine göre sırala
    apps.sort((a, b) => b.totalTime.compareTo(a.totalTime));
    
    // Kategori kullanımlarını hesapla
    for (var app in apps) {
      categoryUsage[app.category] = (categoryUsage[app.category] ?? Duration.zero) + app.totalTime;
    }
    
    // Saatlik veriyi parse et (eğer varsa)
    if (stats['hourlyUsage'] != null && stats['hourlyUsage'] is List) {
      List hourlyUsage = stats['hourlyUsage'];
      for (int i = 0; i < 24 && i < hourlyUsage.length; i++) {
        final usage = hourlyUsage[i];
        hourlyData[i] = (usage is num ? usage.toDouble() : 0.0) / 3600000; // ms to hours
      }
    } else {
      // Saatlik veri yoksa, toplam kullanım süresinden tahmini bir dağılım oluştur
      if (apps.isNotEmpty) {
        double totalHours = apps.fold(0, (sum, app) => sum + app.totalTime.inMinutes) / 60.0;
        _generateHourlyDataFromTotal(totalHours, hourlyData);
      }
    }
    
    setState(() {
        _apps = apps;
        _categoryUsage = categoryUsage;
        _hourlyData = hourlyData;
        _usageData = Map<String, dynamic>.from(stats);

    });
  }

  void _generateHourlyDataFromTotal(double totalHours, List<double> hourlyData) {
    // Günün farklı saatlerinde farklı kullanım yoğunluğu simüle et
    List<double> weights = [
      0.1, 0.05, 0.02, 0.01, 0.01, 0.05, 0.15, 0.25, 0.2, 0.15, // 0-9
      0.3, 0.4, 0.35, 0.3, 0.4, 0.35, 0.45, 0.5, 0.4, 0.3,      // 10-19
      0.25, 0.2, 0.15, 0.12                                        // 20-23
    ];
    
    double totalWeight = weights.fold(0, (sum, weight) => sum + weight);
    
    for (int i = 0; i < 24; i++) {
      hourlyData[i] = (totalHours * weights[i] / totalWeight);
    }
  }

  String _getCategoryForApp(String packageName) {
    final package = packageName.toLowerCase();
    
    if (package.contains('whatsapp') || package.contains('telegram') || 
        package.contains('messenger') || package.contains('instagram') ||
        package.contains('twitter') || package.contains('facebook') ||
        package.contains('discord') || package.contains('snapchat')) {
      return 'Sosyal';
    } else if (package.contains('game') || package.contains('play') ||
               package.contains('puzzle') || package.contains('arcade') ||
               package.contains('candy') || package.contains('clash')) {
      return 'Oyunlar';
    } else if (package.contains('photo') || package.contains('camera') ||
               package.contains('edit') || package.contains('design') ||
               package.contains('adobe') || package.contains('canva')) {
      return 'Yaratıcılık';
    } else if (package.contains('shop') || package.contains('store') ||
               package.contains('market') || package.contains('amazon') ||
               package.contains('trendyol') || package.contains('hepsiburada')) {
      return 'Alışveriş';
    } else if (package.contains('youtube') || package.contains('netflix') ||
               package.contains('twitch') || package.contains('video')) {
      return 'Eğlence';
    } else if (package.contains('spotify') || package.contains('music') ||
               package.contains('podcast')) {
      return 'Müzik';
    } else {
      return 'Diğer';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}sa ${duration.inMinutes.remainder(60)}dk';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}dk';
    } else {
      return '${duration.inSeconds}sn';
    }
  }

  Future<Uint8List?> _getAppIcon(String packageName) async {
    try {
      final iconData = await platform.invokeMethod('getAppIcon', {'packageName': packageName});
      return iconData != null ? Uint8List.fromList(iconData.cast<int>()) : null;
    } catch (e) {
      debugPrint('Uygulama ikonu alınamadı: $e');
      return null;
    }
  }

  Widget _buildDateSelector() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.blue),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
              _fetchUsageStats();
            },
          ),
          Text(
            _formatDate(_selectedDate),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.blue),
            onPressed: () {
              if (_selectedDate.isBefore(DateTime.now())) {
                setState(() {
                  _selectedDate = _selectedDate.add(const Duration(days: 1));
                });
                _fetchUsageStats();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUsageChart() {
    List<double> displayData = _hourlyData.any((element) => element > 0) 
        ? _hourlyData 
        : [0.2, 0.1, 0.0, 0.0, 0.0, 0.5, 1.2, 2.1, 1.8, 1.5, 2.3, 3.1, 2.8, 2.5, 3.2, 2.9, 3.5, 4.1, 3.8, 2.2, 1.5, 0.8, 0.4, 0.2];
    
    double maxUsage = displayData.isNotEmpty ? displayData.reduce((a, b) => a > b ? a : b) : 5.0;
    if (maxUsage == 0) maxUsage = 5.0;
    
    return Container(
      height: 240,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Chart
          Expanded(
            flex: 3,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxUsage + 0.5,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const times = ['00', '06', '12', '18'];
                        final index = (value / 6).floor();
                        if (index >= 0 && index < times.length && value % 6 == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              times[index],
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: displayData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: _getHourColor(entry.key),
                        width: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          // Kategoriler
          const SizedBox(height: 16),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildCategoryItems(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getHourColor(int hour) {
    // Hafta sonu için farklı renk
    if (_selectedDate.weekday == 6 || _selectedDate.weekday == 7) {
      return Colors.cyan;
    }
    // Gece saatleri için farklı renk
    if (hour >= 22 || hour <= 6) {
      return Colors.purple;
    }
    return Colors.blue;
  }

  List<Widget> _buildCategoryItems() {
    if (_categoryUsage.isEmpty) {
      return [
        _buildCategoryItem('Sosyal', '0dk', Colors.blue),
        _buildCategoryItem('Oyunlar', '0dk', Colors.cyan),
        _buildCategoryItem('Yaratıcılık', '0dk', Colors.orange),
      ];
    }
    
    List<Widget> items = [];
    List<MapEntry<String, Duration>> sortedCategories = _categoryUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    List<MapEntry<String, Duration>> topCategories = sortedCategories.take(3).toList();
    
    for (var entry in topCategories) {
      Color color = _getCategoryColor(entry.key);
      items.add(_buildCategoryItem(entry.key, _formatDuration(entry.value), color));
    }
    
    // Eğer 3'ten az kategori varsa, boş kategoriler ekle
    while (items.length < 3) {
      if (items.length == 0) {
        items.add(_buildCategoryItem('Sosyal', '0dk', Colors.blue));
      } else if (items.length == 1) {
        items.add(_buildCategoryItem('Oyunlar', '0dk', Colors.cyan));
      } else {
        items.add(_buildCategoryItem('Yaratıcılık', '0dk', Colors.orange));
      }
    }
    
    return items;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Sosyal':
        return Colors.blue;
      case 'Oyunlar':
        return Colors.cyan;
      case 'Yaratıcılık':
        return Colors.orange;
      case 'Alışveriş':
        return Colors.green;
      case 'Eğlence':
        return Colors.red;
      case 'Müzik':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCategoryItem(String title, String time, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAppsList() {
    List<AppUsage> displayApps = _apps.isNotEmpty ? _apps : [];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'EN ÇOK KULLANILANLAR',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Kategorileri göster
                  },
                  child: const Text(
                    'KATEGORİLERİ GÖSTER',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (displayApps.isEmpty && !_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      _errorMessage.isNotEmpty 
                          ? _errorMessage 
                          : 'Bu tarih için kullanım verisi bulunamadı',
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    if (_errorMessage.contains('İzin') || _errorMessage.contains('PERMISSION'))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ElevatedButton(
                          onPressed: _requestUsagePermission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('İzin Ver'),
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            ...displayApps.take(10).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final app = entry.value;
              return _buildAppItem(app, index == (displayApps.length - 1) || index == 9);
            }).toList(),
          if (displayApps.length > 10)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // Daha fazla göster
                  },
                  child: const Text(
                    'Daha Fazla',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppItem(AppUsage app, bool isLast) {
  return FutureBuilder<Uint8List?>(
    future: _getAppIcon(app.packageName),
    builder: (context, snapshot) {
      Widget iconWidget;
      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
        iconWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            snapshot.data!,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        );
      } else {
        iconWidget = Icon(
          _getDefaultIcon(app.name),
          color: Colors.white,
          size: 24,
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: !isLast
              ? const Border(
                  bottom: BorderSide(color: Color(0xFF2C2C2E), width: 0.5),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                app.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              app.usage,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      );
    },
  );
}


  Widget _buildBottomSection() {
    int totalNotifications = _usageData['notifications'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BİLDİRİMLER',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _formatDate(_selectedDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '$totalNotifications bildirim',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
IconData _getDefaultIcon(String appName) {
  final name = appName.toLowerCase();
  if (name.contains('whatsapp')) return Icons.message;
  if (name.contains('instagram')) return Icons.camera_alt;
  if (name.contains('youtube')) return Icons.play_arrow;
  if (name.contains('photo') || name.contains('gallery')) return Icons.photo_library;
  if (name.contains('shop') || name.contains('store')) return Icons.shopping_bag;
  if (name.contains('search') || name.contains('find')) return Icons.search;
  if (name.contains('game')) return Icons.sports_esports;
  if (name.contains('music') || name.contains('spotify')) return Icons.music_note;
  if (name.contains('video')) return Icons.ondemand_video;
  if (name.contains('browser') || name.contains('chrome')) return Icons.language;
  if (name.contains('mail')) return Icons.email;
  if (name.contains('discord')) return Icons.forum;
  if (name.contains('telegram')) return Icons.send;
  if (name.contains('facebook')) return Icons.facebook;
  if (name.contains('twitter')) return Icons.alternate_email;
  return Icons.apps;
}


  String _formatDate(DateTime date) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    
    if (_isSameDay(date, DateTime.now())) {
      return 'Bugün, ${date.day} ${months[date.month - 1]}';
    } else if (_isSameDay(date, DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Dün, ${date.day} ${months[date.month - 1]}';
    } else {
      return '${date.day} ${months[date.month - 1]}';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Ekran Süresi",
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _fetchUsageStats,
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.lock_open, color: Colors.blue),
            onPressed: _requestUsagePermission,
            tooltip: 'İzin İste',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildDateSelector(),
                  _buildUsageChart(),
                  _buildAppsList(),
                  _buildBottomSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}

class AppUsage {
  final String name;
  final String packageName; 
  final String usage;
  final Duration totalTime;
  final String category;

  AppUsage({
    required this.name,
    required this.packageName,
    required this.usage,
    required this.totalTime,
    required this.category,
  });
}
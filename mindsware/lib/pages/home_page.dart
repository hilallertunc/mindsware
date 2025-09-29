import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindsware/pages/analysis_page.dart';
import 'package:mindsware/pages/meditation_page.dart';
import 'package:mindsware/pages/place_suggestion_page.dart';
import 'package:mindsware/services/recommendation_service.dart';
import 'package:provider/provider.dart';
import 'package:mindsware/pages/user_data_provider.dart';
import 'package:mindsware/pages/tips_list_page.dart';
import '../widgets/mood_stai_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  String getLevel(int bsmasScore, int screenTime) {
    if (bsmasScore <= 8 && screenTime <= 5) {
      return "Düşük";
    } else if ((bsmasScore <= 14 && screenTime <= 10)) {
      return "Orta";
    } else {
      return "Yüksek";
    }
  }

  String getCbtRecommendation(String level) {
    switch (level) {
      case "Düşük":
        return "Harika! Dijital alışkanlıklarınız dengeli görünüyor. Bu rutini korumaya çalışın.";
      case "Orta":
        return "Dijital alışkanlıklarınızı gözden geçirmeniz faydalı olabilir. Günlük sınırlamalar koymayı deneyin.";
      case "Yüksek":
        return "Dijital bağımlılık belirtileri gözleniyor. Kendinize ekran süresi sınırları koyun, sosyal medya detoksu yapmayı düşünün.";
      default:
        return "";
    }
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = MethodChannel('com.example.usage_stats');
  final RecommendationService _service = RecommendationService();

  int _selectedIndex = 0;

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Future<void> requestUsagePermission() async {
    try {
      await platform.invokeMethod('requestUsagePermission');
    } catch (e) {
      debugPrint('İzin ekranı açılamadı: $e');
    }
  }

  void _getPersonalRecommendation() async {
    final userData = Provider.of<UserDataProvider>(context, listen: false);
    final bsmasScore = userData.bsmasScore;
    final screenTime = userData.screenTime;

    try {
      final result = await _service.getRecommendation(
        bsmas: bsmasScore,
        screentime: screenTime,
      );
    
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Kişisel CBT Önerisi (${result['level']})"),
          content: Text(result['recommendation']!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Kapat"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata oluştu: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bu değerler yalnızca ana sayfa kartlarında gösterim/hesap için.
    final userData = Provider.of<UserDataProvider>(context);
    final bsmasScore = userData.bsmasScore;
    final screenTime = userData.screenTime;
    final level = widget.getLevel(bsmasScore, screenTime);
    final recommendation = widget.getCbtRecommendation(level);
    // recommendation şu an info amaçlı; UI içinde ayrı göstermek istersen kullan.

    return Scaffold(
      // SEKMELERE GÖRE GÖVDEYİ DEĞİŞTİR
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeBody(context),
          const TipsListPage(), // ÖNERİLER & MAKALELER
          const ColoredBox(color: Color(0xFFD6B2C5)), // Ayarlar (placeholder)
        ],
      ),

      // TEK BOTTOM NAV – Flutter'ın kendi BottomNavigationBar'ı
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 239, 126, 164),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Öneriler')
        ],
      ),
    );
  }

  // Uzun ana sayfa içeriğini ayrı bir metoda taşıdık.
  Widget _buildHomeBody(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // Bugün nasılsın?
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.emoji_emotions, size: 32),
                label: const Text('Bugün nasılsın?'),
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => const MoodStaiDialog(),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/icons/meditation.png",
                  width: MediaQuery.of(context).size.width * 0.4,
                )
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Hoşgeldin",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Bugün ne yapmak istersin? ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Meditasyon & Analiz kartları
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 210, 180, 185),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Image.asset(
                                      "assets/icons/girl.png",
                                      width: 80,
                                      height: 80,
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Meditasyon",
                                        style: TextStyle(
                                          color: Color(0xFFF1EAEA),
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const Text(
                                        "Kendine Odaklan",
                                        style: TextStyle(
                                          color: Color(0xFFF1EAEA),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 25),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "3-10 Dakika",
                                            style: TextStyle(
                                              color: Color(0xFFF1EAEA),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (_) => const MeditationPage()),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(255, 123, 106, 106),
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 16,
                                              ),
                                              child: const Text(
                                                "BAŞLA",
                                                style: TextStyle(
                                                  color: Color(0xFFF1EAEA),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(156, 243, 178, 143),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Image.asset(
                                      "assets/icons/analiz.png",
                                      width: 80,
                                      height: 80,
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Analiz",
                                        style: TextStyle(
                                          color: Color(0xFFF1EAEA),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const Text(
                                        "Alışkanlıklarını Analiz Et",
                                        style: TextStyle(
                                          color: Color(0xFFF1EAEA),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 25),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "3-10 Dakika",
                                            style: TextStyle(
                                              color: Color(0xFFF1EAEA),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const AnalysisPage(usageStats: []),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(156, 176, 121, 91),
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 16,
                                              ),
                                              child: const Text(
                                                "BAŞLA",
                                                style: TextStyle(
                                                  color: Color(0xFFF1EAEA),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Mekan Önerileri
                  Container(
                    width: 400,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(29, 53, 87, 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // Metin içeriği
                        const Positioned(
                          top: 15,
                          left: 15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mekan Önerileri",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 241, 224, 224),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Gerçek dünyada bir ",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 241, 224, 224),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                "mola vermeye ne dersin?",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 241, 224, 224),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                "Dijital dünyadan uzaklaşarak",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 241, 224, 224),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                "doğal bir ortamda rahatlamak ",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 241, 224, 224),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                "en uygun mekanları keşfet.",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 241, 224, 224),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Resim
                        Positioned(
                          bottom: 20,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              "assets/icons/mekan.png",
                              width: 180,
                              height: 180,
                            ),
                          ),
                        ),

                        // KEŞFET Butonu - Sağ altta, resmin altında
                        Positioned(
                          bottom: 15,
                          right: 20,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/placeSuggestion');
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(200, 235, 211, 211),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15, 
                                  vertical: 10
                                ),
                                child: const Text(
                                  "KEŞFET",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Moduna Göre
                  Container(
                    width: 400,
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(131, 53, 66, 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        const Positioned(
                          top: 10,
                          left: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Moduna Göre",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Modunu seç öneri verelim.",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Image.asset(
                            "assets/icons/mood_tracker.png",
                            width: 120,
                            height: 80,
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/moodSelector');
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(200, 235, 211, 211),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15, 
                                  vertical: 10
                                ),
                                child: const Text(
                                  "MOOD'LA",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Kişisel öneri butonu
            Center(
              child: ElevatedButton.icon(
                onPressed: _getPersonalRecommendation,
                icon: const Icon(Icons.recommend),
                label: const Text("Kişisel Öneri Al"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade200,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30), // Alt boşluk
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindsware/pages/meditation_detail_page.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});
  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  final List<Map<String, String>> categories = const [
    {'text': 'Tümü', 'emoji': '🌈'},
    {'text': 'Rahatla', 'emoji': '😌'},
    {'text': 'Uyku', 'emoji': '😴'},
    {'text': 'Odaklan', 'emoji': '🤖'},
    {'text': 'Sakinlik', 'emoji': '🧘‍♀️'},
  ];

  final List<Map<String, dynamic>> meditations = const [
    {'title': 'Kaygı','subtitle': 'Stres seviyeni azalt','category': 'Rahatla','backgroundColor': Color(0xFFFFE4E6),'textColor': Colors.black87,'image': 'assets/icons/yoga_pose.jpg'},
    {'title': 'Mutluluk','subtitle': 'Günlük huzurunu bul','category': 'Sakinlik','backgroundColor': Color(0xFFFEF3E2),'textColor': Colors.black87,'image': 'assets/icons/flower.jpg'},
    {'title': 'Odaklanma','subtitle': 'Verimliliğini artır','category': 'Odaklan','backgroundColor': Color(0xFFE7F7D3),'textColor': Colors.black87,'image': 'assets/icons/focus.jpg'},
    {'title': 'Derin Uyku','subtitle': 'Rahat bir uyku çek','category': 'Uyku','backgroundColor': const Color(0xFFb6dbf7),'textColor': Colors.black87,'image': 'assets/icons/deep_sleep.png'},
  ];

  int selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));

    final selected = categories[selectedCategoryIndex]['text']!;
    final filtered = selected == 'Tümü'
        ? meditations
        : meditations.where((m) => m['category'] == selected).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Meditasyon'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity, height: 240,
                  child: Image.asset('assets/icons/meditation.jpg', fit: BoxFit.cover),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Meditasyon Planı', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                      SizedBox(height: 6),
                      Text('Kendi huzur yolculuğunu başlat', style: TextStyle(fontSize: 16, color: Colors.black54)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 56,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final c = categories[i];
                        final sel = i == selectedCategoryIndex;
                        return GestureDetector(
                          onTap: () => setState(() => selectedCategoryIndex = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? Colors.green.withOpacity(0.12) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: sel ? Colors.green : Colors.transparent, width: 1.2),
                            ),
                            child: Row(children: [
                              Text(c['emoji']!, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(c['text']!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: sel ? Colors.green : Colors.black87)),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: filtered.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _card(
                        title: m['title'], subtitle: m['subtitle'],
                        backgroundColor: m['backgroundColor'],
                        textColor: m['textColor'], image: m['image'],
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({
    required String title, required String subtitle,
    required Color backgroundColor, required Color textColor, required String image,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MeditationDetailScreen(title: title))),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 140, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.8))),
              ]),
            ),
            const SizedBox(width: 16),
            Image.asset(image, height: 84),
          ],
        ),
      ),
    );
  }
}

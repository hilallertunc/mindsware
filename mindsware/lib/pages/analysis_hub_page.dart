
import 'package:flutter/material.dart';
import 'package:mindsware/pages/analysis_page.dart';
import 'package:mindsware/pages/tips_list_page.dart';

class AnalysisHubPage extends StatelessWidget {
  const AnalysisHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analiz')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.query_stats),
            title: const Text('Alışkanlık Analizi'),
            subtitle: const Text('Kullanım istatistiklerini incele'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AnalysisPage(usageStats: []),
              ),
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: const Text('Öneriler & Makaleler'),
            subtitle: const Text('Dijital farkındalık kartları ve kaynaklar'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TipsListPage()),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

final List<String> staiQuestions = [
  "Şu anda sakinim",
  "Kendimi emniyette hissediyorum",
  "Su anda sinirlerim gergin",
  "Pişmanlık duygusu içindeyim",
  "Şu anda huzur içindeyim",
  "Şu anda hiç keyfim yok",
  "Başıma geleceklerden endişe ediyorum",
  "Kendimi dinlenmiş hissediyorum",
  "Şu anda kaygılıyım",
  "Kendimi rahat hissediyorum",
  "Kendime güvenim var",
  "Şu anda asabım bozuk",
  "Çok sinirliyim",
  "Sinirlerimin çok gergin olduğunu hissediyorum",
  "Kendimi rahatlamış hissediyorum",
  "Şu anda halimden memnunum",
  "Şu anda endişeliyim",
  "Heyecandan kendimi şaşkına dönmüş hissediyorum",
  "Şu anda sevinçliyim",
  "Şu anda keyfim yerinde"
];

class MoodStaiDialog extends StatefulWidget {
  const MoodStaiDialog({Key? key}) : super(key: key);

  @override
  State<MoodStaiDialog> createState() => _MoodStaiDialogState();
}

class _MoodStaiDialogState extends State<MoodStaiDialog> {
  int? selectedIndex;
  bool showSuggestion = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: 350,
          child: showSuggestion
              ? _buildSuggestion(context)
              : _buildStaiList(context),
        ),
      ),
    );
  }

  Widget _buildStaiList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Şu anda kendini nasıl hissediyorsun?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 18),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: staiQuestions.length,
            separatorBuilder: (context, index) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Card(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
                      : Colors.white,
                  elevation: isSelected ? 6 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                    child: Text(
                      staiQuestions[index],
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 18),
        ElevatedButton(
          onPressed: selectedIndex != null
              ? () {
                  setState(() {
                    showSuggestion = true;
                  });
                }
              : null,
          child: Text('Devam'),
        ),
      ],
    );
  }

  Widget _buildSuggestion(BuildContext context) {
    String suggestion = _generateSuggestion(selectedIndex);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lightbulb, color: Theme.of(context).colorScheme.primary, size: 48),
        SizedBox(height: 16),
        Text('Bugün için önerin:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Text(suggestion, style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Kapat'),
        ),
      ],
    );
  }

  String _generateSuggestion(int? index) {
    if (index == null) return "Kendini nasıl hissettiğini seçmelisin.";
    final text = staiQuestions[index].toLowerCase();
    if (text.contains("gergin") || text.contains("asabım") || text.contains("endişe") || text.contains("kaygılı")) {
      return "Bugün biraz gergin veya endişeli hissediyorsun. Kısa bir yürüyüş, nefes egzersizi veya sevdiğin bir müzik sana iyi gelebilir.";
    } else if (text.contains("huzur") || text.contains("sakin") || text.contains("rahat") || text.contains("memnunum") || text.contains("sevinçli") || text.contains("keyfim")) {
      return "Harika! Bu güzel ruh halini sürdürmek için sevdiğin bir aktiviteye zaman ayırabilirsin.";
    } else if (text.contains("pişmanlık") || text.contains("keyfim yok") || text.contains("hiç keyfim yok")) {
      return "Biraz düşük hissediyor olabilirsin. Sevdiğin bir kitap, kahve veya doğada kısa bir yürüyüş iyi gelebilir.";
    } else if (text.contains("güvenim var")) {
      return "Kendine güvenmen harika! Bugün yeni bir şey denemek için güzel bir gün olabilir.";
    } else {
      return "Dijital molalar vermeyi unutma. Kendine zaman ayırmak için bir kitap veya kahve öneriyoruz.";
    }
  }
} 
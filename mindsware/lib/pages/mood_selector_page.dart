import 'package:flutter/material.dart';

class MoodSelectorPage extends StatefulWidget {
  const MoodSelectorPage({super.key});

  @override
  State<MoodSelectorPage> createState() => _MoodSelectorPageState();
}

class _MoodSelectorPageState extends State<MoodSelectorPage> {
  double _moodValue = 2.0; // Slider'ın başlangıç değeri (Neutral)

  final List<String> _moodImagePaths = [
    'assets/icons/kotu.png',  
    'assets/icons/uzgun.png',   
    'assets/icons/normal.png', 
    'assets/icons/iyi.png',   
    'assets/icons/cok_iyi.png', 
  ];

  final List<String> _moodLabels = [
    "Çok Kötü",   
    "Kötü",  
    "Orta",     
    "İyi",   
    "Çok İyi", 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mood Seçici")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, 
          children: [
            const SizedBox(height: 30),
            const Text(
              "Bugün nasıl hissediyorsun?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            
            CustomPaint(
              size: Size(300, 150), // Yarım dairenin boyutu
              painter: ArcPainter(moodValue: _moodValue),
            ),
            const SizedBox(height: 20),
            // Mood'a göre emoji resmi
            Image.asset(
              _moodImagePaths[_moodValue.toInt()],
              height: 100,  
              width: 100,
            ),
            const SizedBox(height: 10),
            Text(
              _moodLabels[_moodValue.toInt()],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Slider to select mood
            Slider(
              value: _moodValue,
              min: 0,
              max: 4,
              divisions: 4,
              activeColor: _getColorForMood(),
              inactiveColor: Colors.grey,
              label: _moodLabels[_moodValue.toInt()],
              onChanged: (double newValue) {
                setState(() {
                  _moodValue = newValue;
                });
              },
            ),

            const Spacer(), // Bu satır ile resim slider'dan tamamen alt kısma yerleşir.

            // Resmi en alta taşıdık
           // Image.asset(
             // 'assets/icons/emojis.png', // Burada resim dosyanızı kullanın
             // height: 450, // Resmin boyutunu ayarladık
             // width: 400,
           // ),
          ],
        ),
      ),
    );
  }

  // Mood seviyesine göre renk seçimi
  Color _getColorForMood() {
    if (_moodValue <= 1) {
      return Colors.red; // Worst ve Poor
    } else if (_moodValue == 2) {
      return Colors.yellow; // Fair
    } else if (_moodValue == 3) {
      return Colors.lightGreen; // Good
    } else {
      return Colors.green; // Excellent
    }
  }
}

class ArcPainter extends CustomPainter {
  final double moodValue;

  ArcPainter({required this.moodValue});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    // Yarım daire için renk geçişi
    var gradient = SweepGradient(
      colors: [Colors.red, Colors.orange, Colors.yellow, Colors.lightGreen, Colors.green],
      startAngle: 0.0,
      endAngle: 3.14, // Yarım daire
    );

    paint.shader = gradient.createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height), radius: size.width / 2));

    // Yarım daireyi çiz
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height), radius: size.width / 2),
      3.14, // Başlangıç açısı (yarım daire)
      3.14 * moodValue / 4, // Mood değerine göre yay açısı
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

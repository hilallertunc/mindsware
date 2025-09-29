import 'package:flutter/material.dart';
import 'package:mindsware/pages/intro_page1.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // soft gri-beyaz arkaplan
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // her şeyi ortala
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/info.png',
                  height: 280,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),

                // Başlık
                const Text(
                  'Dijital Davranış Değerlendirmesi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Açıklama metni
                const Text(
                  'Bu kısa değerlendirme, sosyal medya kullanım alışkanlıklarınızı analiz ederek refahınızı desteklemeyi amaçlamaktadır. Sorular, uluslararası geçerliliği olan Bergen Sosyal Medya Bağımlılığı Ölçeği (BSMAS) esas alınarak hazırlanmıştır.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF757575),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // CTA butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const IntroPage1()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFfcb7d4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Değerlendirmeye Başla',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

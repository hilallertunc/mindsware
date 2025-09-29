import 'package:flutter/material.dart';

import 'package:mindsware/pages/home_page.dart';
import 'package:mindsware/pages/login_page.dart';
import 'package:mindsware/pages/sign_in_page.dart';
import 'package:mindsware/pages/info_page.dart';
// Bildirim servisini import et
import 'package:mindsware/services/notification_service.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 48),
            
                Image.asset(
                  "assets/icons/mindsware.png",
                  width: w * 0.8,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 16),
                const Text(
                  "Ekrana Değil,",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.pink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  "Hayata Dokun.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.pink,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 24),

                // --- Kayıt Ol Butonu ---
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInPage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 238, 43, 105),
                          Color.fromARGB(255, 240, 119, 153),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Kayıt Ol",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // --- Giriş Yap Butonu (outlined) ---
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(255, 238, 43, 105),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "Giriş Yap",
                      style: TextStyle(
                        color: Color.fromARGB(255, 238, 43, 105),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // --- Giriş yapmadan devam et ---
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const InfoPage()),
                    );
                  },
                  child: const Text(
                    "Giriş yapmadan devam et",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Test butonları (isteğe bağlı)
                
                ElevatedButton(
                  onPressed: () async {
                    await NotificationService().showNow(
                      title: "MindsWare",
                      body: "Bu bir test bildirimi!",
                      payload: "open_analysis",
                    );
                  },
                  child: const Text("📢 Anlık Bildirim Test"),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    await NotificationService().scheduleOneOff(
                      after: const Duration(seconds: 10),
                      title: "MindsWare",
                      body: "10 saniye sonra geldim 🚀",
                      payload: "open_analysis",
                    );
                  },
                  child: const Text("⏱ 10sn Sonra Bildirim Test"),
                ),
                

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

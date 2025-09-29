import 'package:flutter/material.dart';
import 'package:mindsware/pages/intro_page4.dart';
import 'package:mindsware/pages/user_data_provider.dart';
import 'package:provider/provider.dart';


class IntroPage3 extends StatefulWidget {
  const IntroPage3({super.key});

  @override
  State<IntroPage3> createState() => _IntroPage3State();
}

class _IntroPage3State extends State<IntroPage3> {
  int? _selectedValue;

  final List<Map<String, dynamic>> _likertOptions = [
    {'value': 1, 'label': 'Hiçbir zaman'},
    {'value': 2, 'label': 'Nadiren'},
    {'value': 3, 'label': 'Bazen'},
    {'value': 4, 'label': 'Sık sık'},
    {'value': 5, 'label': 'Çok sık'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF264414),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.3 * 255).toInt()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Soru 3/6',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Icon(Icons.repeat, size: 80, color: Colors.white),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.1 * 255).toInt()),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Sosyal medyayı kullanmayı bırakmakta zorlandınız mı?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ..._likertOptions.map((option) {
                return Card(
                  color: _selectedValue == option['value']
                      ? Colors.white.withAlpha((0.9 * 255).toInt())
                      : Colors.white.withAlpha((0.1 * 255).toInt()),
                  child: RadioListTile<int>(
                    value: option['value'],
                    groupValue: _selectedValue,
                    activeColor: Colors.white,
                    onChanged: (val) {
                      setState(() {
                        _selectedValue = val;
                      });

                      // Provider üzerinden BSMAS cevabını ekle
                      context.read<UserDataProvider>().addBsmasAnswer(val!);

                      // Sonraki sayfaya yönlendir
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const IntroPage4()),
                      );
                    },
                    title: Text(
                      option['label'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),

            ],
          ),
        ),
      ),
    );
  }
}

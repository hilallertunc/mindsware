import 'package:flutter/material.dart';
import 'package:mindsware/pages/intro_page3.dart';
import 'package:mindsware/pages/user_data_provider.dart';
import 'package:provider/provider.dart';


class IntroPage2 extends StatefulWidget {
  const IntroPage2({super.key});

  @override
  State<IntroPage2> createState() => _IntroPage2State();
}

class _IntroPage2State extends State<IntroPage2> {
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
      backgroundColor: const Color(0xFF99B7F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF203F9A).withAlpha((0.3 * 255).toInt()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Soru 2/6',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF203F9A),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Icon(Icons.trending_up, size: 80, color: Color(0xFF203F9A)),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF203F9A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Sosyal medyayı giderek daha fazla kullanma arzusu hissettiniz mi?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF203F9A),
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
                    activeColor: const Color(0xFF203F9A),
                    onChanged: (val) {
                      setState(() {
                        _selectedValue = val;
                      });

                      // BSMAS cevabını provider üzerinden ekle
                      context.read<UserDataProvider>().addBsmasAnswer(val!);

                      // Bir sonraki sayfaya geç
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const IntroPage3()),
                      );
                    },
                    title: Text(
                      option['label'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF203F9A),
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

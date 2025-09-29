import 'package:flutter/material.dart';
import 'package:mindsware/pages/intro_page6.dart';
import 'package:mindsware/pages/user_data_provider.dart';
import 'package:provider/provider.dart';


class IntroPage5 extends StatefulWidget {
  const IntroPage5({super.key});

  @override
  State<IntroPage5> createState() => _IntroPage5State();
}

class _IntroPage5State extends State<IntroPage5> {
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
      backgroundColor: const Color(0xFFA6171C),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.3 * 255).toInt()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Soru 5/6',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Icon(Icons.people, size: 80, color: Colors.white),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Sosyal medya kullanımınız nedeniyle sosyal çevrenizle sorun yaşadınız mı?',
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

                      context.read<UserDataProvider>().addBsmasAnswer(val!);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const IntroPage6()),
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

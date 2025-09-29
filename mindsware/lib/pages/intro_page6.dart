import 'package:flutter/material.dart';
import 'package:mindsware/pages/home_page.dart';
import 'package:mindsware/pages/user_data_provider.dart';
import 'package:mindsware/services/survey_manager.dart'; 
import 'package:provider/provider.dart';

class IntroPage6 extends StatefulWidget {
  const IntroPage6({super.key});

  @override
  State<IntroPage6> createState() => _IntroPage6State();
}

class _IntroPage6State extends State<IntroPage6> {
  int? _selectedValue;
  bool _submitting = false;

  final List<Map<String, dynamic>> _likertOptions = const [
    {'value': 1, 'label': 'Hiçbir zaman'},
    {'value': 2, 'label': 'Nadiren'},
    {'value': 3, 'label': 'Bazen'},
    {'value': 4, 'label': 'Sık sık'},
    {'value': 5, 'label': 'Çok sık'},
  ];

  Future<void> _showSubmittedDialog() async {
    const successGreen = Color(0xFF50C878);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle, size: 48, color: successGreen),
              SizedBox(height: 12),
              Text(
                'Cevaplarınız Alındı',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: const Text(
            'Teşekkürler! Değerlendirmenizi kaydettik. '
            'Şimdi ana sayfaya yönlendirileceksiniz.',
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: successGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: const Text('Devam et'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSubmit(int val) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    context.read<UserDataProvider>().addBsmasAnswer(val);
    await _showSubmittedDialog();
    await SurveyManager.markSurveyCompletedNow();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFBCBB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFA6171C).withAlpha((0.3 * 255).toInt()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Soru 6/6',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFA6171C),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Icon(Icons.emoji_emotions, size: 80, color: Color(0xFFA6171C)),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFA6171C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Sosyal medya kullanmadığınızda huzursuz, gergin veya mutsuz hissettiniz mi?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFA6171C),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ..._likertOptions.map((option) {
                final value = option['value'] as int;
                return Opacity(
                  opacity: _submitting ? 0.6 : 1.0,
                  child: IgnorePointer(
                    ignoring: _submitting,
                    child: Card(
                      color: _selectedValue == value
                          ? Colors.white.withAlpha((0.9 * 255).toInt())
                          : Colors.white.withAlpha((0.1 * 255).toInt()),
                      child: RadioListTile<int>(
                        value: value,
                        groupValue: _selectedValue,
                        activeColor: const Color(0xFFA6171C),
                        onChanged: (val) async {
                          setState(() => _selectedValue = val);
                          await _handleSubmit(val!);
                        },
                        title: Text(
                          option['label'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFA6171C),
                          ),
                        ),
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

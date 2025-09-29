import 'package:flutter/material.dart';
import 'package:mindsware/pages/intro_page1.dart';
import 'package:mindsware/pages/welcome_page.dart';
import 'package:mindsware/services/survey_manager.dart';

class PostLoginDecider extends StatefulWidget {
  const PostLoginDecider({super.key});

  @override
  State<PostLoginDecider> createState() => _PostLoginDeciderState();
}

class _PostLoginDeciderState extends State<PostLoginDecider> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    await Future.delayed(Duration.zero);

    final show = await SurveyManager.shouldShowSurvey();
    if (!mounted) return;

    if (show) {
      await SurveyManager.markSurveyShownNow();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const IntroPage1()),
      );
    } else {
    
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Center(child: CircularProgressIndicator())),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mindsware/pages/analysis_page.dart';
import 'package:mindsware/pages/mood_selector_page.dart';
import 'package:mindsware/pages/place_suggestion_page.dart';
import 'package:mindsware/pages/user_data_provider.dart';
import 'package:mindsware/pages/welcome_page.dart';
import 'package:mindsware/pages/info_page.dart';
import 'package:mindsware/pages/intro_page1.dart';
import 'package:mindsware/pages/intro_page2.dart';
import 'package:mindsware/pages/intro_page3.dart';
import 'package:mindsware/pages/intro_page4.dart';
import 'package:mindsware/pages/intro_page5.dart';
import 'package:mindsware/pages/intro_page6.dart';
import 'package:mindsware/pages/login_decider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Bildirim servisi
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserDataProvider(),
      child: const MyApp(),
    ),
  );

  await NotificationService().scheduleDailyAt(hour: 17, minute: 35);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey, 
      debugShowCheckedModeBanner: false,
      title: 'MindsWare',
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/postLogin': (context) => const PostLoginDecider(),
        '/moodSelector': (context) => const MoodSelectorPage(),
        '/analysis': (context) => const AnalysisPage(usageStats: []),
        '/info': (context) => const InfoPage(),
        '/intro1': (context) => const IntroPage1(),
        '/intro2': (context) => const IntroPage2(),
        '/intro3': (context) => const IntroPage3(),
        '/intro4': (context) => const IntroPage4(),
        '/intro5': (context) => const IntroPage5(),
        '/intro6': (context) => const IntroPage6(),
        '/placeSuggestion': (context) => const PlaceSuggestionPage(),
        '/welcome': (context) => WelcomePage(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

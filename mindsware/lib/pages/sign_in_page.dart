import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mindsware/pages/home_page.dart';
import 'package:mindsware/pages/info_page.dart';

// kayıt sayfası
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _obscureText = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

// Google girisi icin
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InfoPage()),
        );
      }
    } catch (e) {
      debugPrint("Google Girişi Hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Color.fromARGB(255, 243, 33, 68),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 70.0),
                child: Image(
                  image: AssetImage('assets/icons/girl.png'),
                  width: 228,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: 50.0,
            left: 10.0,
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.grey,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 250.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    const TextField(
                      decoration: InputDecoration(
                        label: Text(
                          "Ad Soyad",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const TextField(
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.mail, color: Colors.grey),
                        label: Text(
                          "Gmail",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        label: const Text(
                          "Şifre",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Şifremi unuttum ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        width: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 255, 136, 156),
                              Color.fromARGB(255, 229, 161, 185),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Giriş Yap",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 255, 136, 156),
                            Color.fromARGB(255, 229, 161, 185),
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                          onPressed: _signInWithGoogle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 249, 244, 245),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 40),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Image.asset(
                              "assets/icons/icons8-google-50.png",
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Google ile devam et",
                              style: TextStyle(
                                color: Color.fromARGB(255, 29, 29, 29),
                              ),
                            )
                          ])),
                    ),
                    const SizedBox(height: 40), 
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
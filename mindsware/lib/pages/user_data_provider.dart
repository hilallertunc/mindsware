import 'package:flutter/material.dart';

class UserDataProvider with ChangeNotifier {
  List<int> _bsmasAnswers = [];
  int _screenTime = 0;

  List<int> get bsmasAnswers => _bsmasAnswers;
  int get screenTime => _screenTime;

  /// Toplam BSMAS puanı hesaplanır (örneğin: 5 sorudan 4+3+2+5+1 = 15 gibi)
  int get bsmasScore =>
      _bsmasAnswers.isNotEmpty ? _bsmasAnswers.reduce((a, b) => a + b) : 0;

  /// BSMAS cevaplarını ekler (her soruda çağrılır)
  void addBsmasAnswer(int value) {
    _bsmasAnswers.add(value);
    notifyListeners();
  }

  /// BSMAS verilerini sıfırlar (örneğin testi yeniden başlatınca)
  void resetBsmasAnswers() {
    _bsmasAnswers = [];
    notifyListeners();
  }

  /// Ekran süresi (dakika cinsinden) ayarlanır
  void setScreenTime(int minutes) {
    _screenTime = minutes;
    notifyListeners();
  }
}

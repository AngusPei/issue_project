import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class SideState extends ChangeNotifier {
  final int max = 150;

  int _currentIndex = 0;

  set currentIndex(int forward) {
    _currentIndex += forward;
    if (_currentIndex > max) {
      _currentIndex = 0;
    } else if (_currentIndex < 0) {
      _currentIndex = max;
    }
//    notifyListeners();
  }

  int get currentIndex => _currentIndex;
}

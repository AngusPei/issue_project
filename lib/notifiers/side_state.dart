import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class SideState extends ChangeNotifier {
  final int max = 150;
  static List<ByteData> images = [];

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  int frame(int forward) {
    _currentIndex += forward;

    if (_currentIndex > max) {
      _currentIndex = 0;
    } else if (_currentIndex < 0) {
      _currentIndex = max;
    }

    return _currentIndex;
  }

  /// 初始化所有的动画图片
  loadImages() async {
    images.clear();

    /// 预缓存侧轴图片
    for (var i = 0; i < max + 1; i++) {
      ByteData data = await rootBundle.load('assets/images/side/side_$i.jpg');
      images.add(data);

      debugPrint('assets/images/side/side_$i.jpg');
    }
  }
}

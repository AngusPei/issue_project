import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notifiers/side_state.dart';

class SidePage extends StatefulWidget {
  static final routeName = '/sideView';

  @override
  _SidePageState createState() => _SidePageState();
}

enum ImageFormat { png, jpg, gif, webp }

extension ImageFormatExtension on ImageFormat {
  String get value => ['png', 'jpg', 'gif', 'webp'][index];
}

class ImageUtils {
  static ImageProvider getAssetImage(String name,
      {ImageFormat format = ImageFormat.png}) {
    return AssetImage(getImgPath(name, format: format));
  }

  static String getImgPath(String name,
      {ImageFormat format = ImageFormat.png}) {
    return 'assets/images/$name.${format.value}';
  }
}

class _SidePageState extends State<SidePage>
    with SingleTickerProviderStateMixin {
  Animation<int> _animation;
  AnimationController _animationController;

  int _forward = 0;

  Future<void> _preCacheImage(context) async {
    for (var i = 0; i < 150 + 1; i++) {
      try {
        await precacheImage(
            ImageUtils.getAssetImage('side/side_$i', format: ImageFormat.jpg),
            context);
        debugPrint('assets/images/side/side_$i.jpg');
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    await Provider.of<SideState>(context, listen: false).loadImages();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _preCacheImage(context).then((value) {
        setState(() {});
      });
    });

    _animationController = new AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this)..addListener(() {

    })..addStatusListener((status) {

    });

    _animation = new IntTween(begin: 0, end: 10).animate(_animationController)
      ..addListener(() {
        setState(() {
          debugPrint('update _animation');
        });
      })
      ..addStatusListener((state) {
        debugPrint('animation state : $state');
        if (state == AnimationStatus.completed) {
          _animationController.reset();
        }
      });
  }

  @override
  void dispose() {
    _animationController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0,
      ),
      body: buildBody(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () {
              _forward = -2;
              _animationController.forward();
            },
            heroTag: "right_rotation",
            child: Container(
              child: Image.asset(
                'assets/images/right_rotation.png',
                width: 40,
                height: 40,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: FloatingActionButton(
              heroTag: "left_rotation",
              onPressed: () {
                _forward = 2;
                _animationController.forward();
              },
              child: Container(
                child: Image.asset(
                  'assets/images/left_rotation.png',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.height > size.width ? size.width : size.height;

    return Container(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,

        /// 此处需要细化
        onPanUpdate: (DragUpdateDetails details) {
          if (details.delta == Offset.zero) return;

          int forward = details.delta.dx ~/ 10;

          if (forward.abs() < 4) {
            forward = (details.delta.dx < 0 ? 4 : -4);
          } else if (forward.abs() < 15) {
            forward = (details.delta.dx < 0 ? 6 : -6);
          } else {
            forward = (details.delta.dx < 0 ? 8 : -8);
          }

          _forward = forward;
          _animationController.forward();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: _buildPlayAnimation(width),
          ),
        ), //        child: Container(
      ),
    );
  }

  _buildPlayAnimation(double width) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget child) {
        int frame =
            Provider.of<SideState>(context, listen: false).frame(_forward);
        if (SideState.images.length > frame) {
          debugPrint('assets/images/side/side_$frame.jpg');

          return Container(
            width: width,
            height: width,
            key: ValueKey('side_$frame'),
//            decoration: BoxDecoration(
//                color: Colors.purple,
//                image: DecorationImage(
//                    image: ImageUtils.getAssetImage('side/side_$frame',
//                        format: ImageFormat.jpg),
//                    fit: BoxFit.fill)),
            child: Image.memory(
              SideState.images[frame].buffer.asUint8List(),
              width: width,
              height: width,
              gaplessPlayback: true,
            ),
          );
        } else {
          debugPrint('err: assets/images/side/side_$frame.jpg');
          return Container(
            width: width,
            height: width,
          );
        }
      },
    );
  }

  @override
  void didUpdateWidget(SidePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('didUpdateWidget');
  }
}

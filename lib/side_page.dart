import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  Animation<int> _animation;
  AnimationController _animationController;

  int _forward = 0;
  List<MemoryImage> images = [];

  double _imageScale = 0.8;

  bool _isScale = false;

  Future<void> _preCacheImage(context) async {
    for (var i = 0; i < 150 + 1; i++) {
      try {
        await precacheImage(
            ImageUtils.getAssetImage('side/side_$i', format: ImageFormat.png),
            context);
        debugPrint('assets/images/side/side_$i.png');
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    await loadImages();
  }

  Future<void> _preCacheImage2(context) async {
    for (var i = 0; i < 150 + 1; i++) {
      try {
        await precacheImage(
            ImageUtils.getAssetImage('side/side_640x480_long',
                format: ImageFormat.gif),
            context);
        await precacheImage(
            ImageUtils.getAssetImage('side/side_720x540_long',
                format: ImageFormat.gif),
            context);
        await precacheImage(
            ImageUtils.getAssetImage('side/side_1024x768_long',
                format: ImageFormat.gif),
            context);
        await precacheImage(
            ImageUtils.getAssetImage('side/side_500x375_long',
                format: ImageFormat.gif),
            context);
        await precacheImage(
            ImageUtils.getAssetImage('side/side_800x600_long',
                format: ImageFormat.gif),
            context);
        await precacheImage(
            ImageUtils.getAssetImage('side/side_800x600_long_png',
                format: ImageFormat.gif),
            context);
      } catch (e) {
        debugPrint(e.toString());
      }
    }

//    await loadImages();
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
        duration: const Duration(milliseconds: 400), vsync: this);

    _animation = new IntTween(begin: 0, end: 4).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed ||
            state == AnimationStatus.dismissed) {
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
    super.build(context);
    var size = MediaQuery.of(context).size;
    final width = size.height > size.width ? size.width : size.height;

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
          IconButton(
            onPressed: () {
              _forward = -1;
              _animationController.forward();
            },
            iconSize: 40,
            icon: Image.asset(
              'assets/images/right_rotation.png',
              width: 40,
              height: 40,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: IconButton(
              onPressed: () {
                _forward = 1;
                _animationController.forward();
              },
              icon: Image.asset(
                'assets/images/left_rotation.png',
              ),
              iconSize: 40,
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
        onDoubleTap: () {
          if (_imageScale != 0.8) {
            _imageScale = 0.8;
            setState(() {});
          } else if (_imageScale != 1.5) {
            _imageScale = 1.5;
            setState(() {});
          }
        },
        onScaleStart: (ScaleStartDetails details) {
          _isScale = true;
        },
        onScaleEnd: (ScaleEndDetails details) {
          _isScale = false;
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
//          if(details.scale == 1)  return;
          if (details.scale < 1 && _imageScale != 0.5) {
            _imageScale = 0.5;
            debugPrint('_imageScae=====$_imageScale');
            setState(() {});
          } else if (details.scale > 1 && _imageScale != 1.5) {
            _imageScale = 1.5;
            debugPrint('_imageScae=====$_imageScale');
            setState(() {});
          }
        },
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          if (details.delta == Offset.zero || _isScale) return;

          int forward = details.delta.dx ~/ 10;

          if (forward.abs() < 3) {
            forward = (details.delta.dx < 0 ? 1 : -1);
          } else if (forward.abs() < 6) {
            forward = (details.delta.dx < 0 ? 2 : -2);
          } else {
            forward = (details.delta.dx < 0 ? 3 : -3);
          }
          debugPrint('forward:$forward');
          _forward = forward;
          _animationController.forward();
        },
        child: Container(
//          width: double.infinity,
//          height: double.infinity,
          child: Center(
            child: _isScale
                ? Container(
                    width: width * _imageScale,
                    height: width * _imageScale,
                    child: Image(
                      image: images[
                          Provider.of<SideState>(context, listen: false)
                              .currentIndex],
                      gaplessPlayback: true,
                    ),
                  )
                : _buildPlayAnimation(width),
          ),
        ), //        child: Container(
      ),
    );
  }

//  Future<Uint8List> _updateFrame(frame) {
//    return new Future<Uint8List>(() {
//      return images[frame].buffer.asUint8List();
//    });
//  }

  _buildPlayAnimation(double width) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget child) {
        Provider.of<SideState>(context, listen: false).currentIndex = _forward;
        int frame = Provider.of<SideState>(context, listen: false).currentIndex;

        if (images.length > frame) {
          debugPrint('assets/images/side/side_$frame.png');
          return Container(
            width: width * _imageScale,
            height: width * _imageScale,
            child: Image(
              image: images[frame],
              gaplessPlayback: true,
            ),
          );
//          return Image.memory(
//            images[frame].buffer.asUint8List(),
////            key: ValueKey('frame_$frame'),
//            width: width,
//            height: width,
//            gaplessPlayback: true,
//          );
        } else {
          debugPrint('err: assets/images/side/side_$frame.png');
          return Container(
            width: width,
            height: width,
          );
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => false;

  @override
  void didUpdateWidget(SidePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    debugPrint('didUpdateWidget');
  }

  /// 初始化所有的动画图片
  loadImages() async {
    images.clear();

    /// 预缓存侧轴图片
    for (var i = 0; i < 150 + 1; i++) {
      ByteData data = await rootBundle.load('assets/images/side/side_$i.png');
//      images.add(data);
      images.add(MemoryImage(data.buffer.asUint8List(), scale: 0.5));

      debugPrint('assets/images/side/side_$i.png');
    }
  }

  _buildPlayGif(double width) {
    return Image.asset(
      'assets/images/side/side_1024x768_long.gif',
      width: width,
      height: width,
//      fit: BoxFit.fitWidth,
    );
  }
}

class ImageContainer extends StatefulWidget {
  final MemoryImage image;

  final double width;

  const ImageContainer({Key key, @required this.image, @required this.width})
      : super(key: key);

  @override
  _ImageContainerState createState() => _ImageContainerState();
}

class _ImageContainerState extends State<ImageContainer> {
  MemoryImage image;

  @override
  void initState() {
    super.initState();
    image = widget.image;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image(
        image: image,
        width: widget.width,
        height: widget.width,
        gaplessPlayback: true,
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace stackTrace,
        ) {
          debugPrint('image error:${error.toString()}');

          return Text('error:${error.toString()}');
        },
      ),
    );
  }
}

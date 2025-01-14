import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LoginBackground extends StatefulWidget {
  final Widget child;

  const LoginBackground({
    super.key,
    required this.child,
  });

  @override
  _LoginBackgroundState createState() => _LoginBackgroundState();
}

class _LoginBackgroundState extends State<LoginBackground> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.asset('assets/videos/login_bg.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..setVolume(0)
      ..play()
      ..setLooping(true)
      ..initialize().then((value) {
        setState(() {}); // Esto debido a que hay veces que no inicia el video a menos que se haga un hot-reload
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/login_bg.png'),
        fit: BoxFit.cover,
      ),
    );

    final videoSize = _controller.value.size;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: backgroundDecoration,
        ),
        ClipRect(
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            alignment: Alignment.center,
            child: Container(
              decoration: backgroundDecoration,
              width: videoSize.width,
              height: videoSize.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        Container(
          color: Color(0x80000000),
        ),
        Container(
          height: double.infinity,
          child: widget.child,
        ),
      ],
    );
  }
}

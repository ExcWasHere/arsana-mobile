import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'video_controls_overlay.dart';

class FullscreenVideoPage extends StatefulWidget {
  final VideoPlayerController controller;
  final double initialSpeed;

  const FullscreenVideoPage({
    super.key,
    required this.controller,
    this.initialSpeed = 1.0,
  });

  @override
  State<FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<FullscreenVideoPage> {
  late double _speed = widget.initialSpeed;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = widget.controller.value.aspectRatio == 0
        ? 16 / 9
        : widget.controller.value.aspectRatio;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              VideoPlayer(widget.controller),
              VideoControlsOverlay(
                controller: widget.controller,
                isFullscreen: true,
                playbackSpeed: _speed,
                onSpeedChanged: (s) => setState(() => _speed = s),
                onToggleFullscreen: () => Navigator.of(context).pop(_speed),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
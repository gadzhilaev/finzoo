import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';

/// Полноэкранное видео после ознакомительных экранов.
class OutroVideoPage extends StatefulWidget {
  const OutroVideoPage({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<OutroVideoPage> createState() => _OutroVideoPageState();
}

class _OutroVideoPageState extends State<OutroVideoPage> {
  late final VideoPlayerController _controller;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = VideoPlayerController.asset(AppAssets.introOutroVideo)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
      });

    _controller.addListener(_onTick);
  }

  void _onTick() {
    if (_finished || !_controller.value.isInitialized) return;
    final value = _controller.value;
    if (value.position >= value.duration && value.duration > Duration.zero) {
      _complete();
    }
  }

  void _complete() {
    if (_finished) return;
    _finished = true;
    widget.onFinished();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _complete,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(
          child: _controller.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const ColoredBox(color: AppColors.cream),
        ),
      ),
    );
  }
}

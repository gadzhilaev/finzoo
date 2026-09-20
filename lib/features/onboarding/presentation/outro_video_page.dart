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
  VideoPlayerController? _controller;
  bool _finished = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPlayer());
  }

  Future<void> _initPlayer() async {
    if (!mounted) return;
    final controller = VideoPlayerController.asset(AppAssets.introOutroVideo);
    _controller = controller;
    controller.addListener(_onTick);

    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {});
      await controller.play();
    } catch (error, stack) {
      debugPrint('outro video init failed: $error\n$stack');
      if (!mounted) return;
      setState(() => _failed = true);
      // После hot restart канал плагина часто мёртв — не блокируем онбординг.
      Future<void>.delayed(const Duration(milliseconds: 400), _complete);
    }
  }

  void _onTick() {
    final controller = _controller;
    if (_finished || controller == null || !controller.value.isInitialized) {
      return;
    }
    final value = controller.value;
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
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_onTick);
      controller.dispose();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _complete,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(
          child: ready
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                )
              : ColoredBox(color: _failed ? AppColors.cream : Colors.black),
        ),
      ),
    );
  }
}

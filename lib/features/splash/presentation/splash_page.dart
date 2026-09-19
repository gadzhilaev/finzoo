import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/layout/design_scale.dart';
import '../../../core/theme/app_colors.dart';
import '../../welcome/presentation/welcome_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _splashDuration = Duration(milliseconds: 1800);

  @override
  void initState() {
    super.initState();
    _goToWelcome();
  }

  Future<void> _goToWelcome() async {
    await Future<void>.delayed(_splashDuration);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const WelcomePage(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = DesignScale.of(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: SvgPicture.asset(
          AppAssets.logo,
          width: scale.s(215),
          height: scale.s(63),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

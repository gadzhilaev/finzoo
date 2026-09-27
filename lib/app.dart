import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/splash_page.dart';

class FinzooApp extends StatelessWidget {
  const FinzooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finzo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.cream,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: const SplashPage(),
      ),
    );
  }
}

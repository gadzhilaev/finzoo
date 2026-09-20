import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Заглушка после онбординга — тот же кремовый фон.
class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.cream,
      body: SizedBox.expand(),
    );
  }
}

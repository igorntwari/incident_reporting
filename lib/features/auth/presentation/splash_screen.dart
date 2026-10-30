import 'package:flutter/material.dart';

import '../../../core/widgets/async_value_view.dart';

/// Shown for the brief moment Firebase restores a persisted session.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: LoadingView());
}

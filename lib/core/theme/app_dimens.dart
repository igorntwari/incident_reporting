import 'package:flutter/widgets.dart';

/// Spacing scale (4pt grid), corner radii and shared sizes.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  static const screenPadding = EdgeInsets.symmetric(horizontal: lg);
}

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;

  static final card = BorderRadius.circular(lg);
  static final input = BorderRadius.circular(md);
  static final pill = BorderRadius.circular(100);
}

abstract final class AppSizes {
  static const buttonHeight = 52.0;
  static const thumbnail = 64.0;
  static const avatar = 44.0;
  static const iconBox = 40.0;
}

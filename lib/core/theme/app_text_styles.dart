import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// The app's type scale. The font family is chosen here and nowhere else.
abstract final class AppTextStyles {
  static TextStyle _base(double size, FontWeight weight, [Color? color]) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.textPrimary,
      );

  static final display = _base(26, FontWeight.w800);
  static final title = _base(20, FontWeight.w700);
  static final heading = _base(17, FontWeight.w700);
  static final subheading = _base(15, FontWeight.w600);
  static final body = _base(14, FontWeight.w500);
  static final bodySecondary = _base(14, FontWeight.w500, AppColors.textSecondary);
  static final caption = _base(12, FontWeight.w500, AppColors.textSecondary);
  static final label = _base(12, FontWeight.w600);
  static final button = _base(15, FontWeight.w700, Colors.white);

  static TextTheme get textTheme => TextTheme(
        headlineMedium: display,
        titleLarge: title,
        titleMedium: heading,
        titleSmall: subheading,
        bodyLarge: body,
        bodyMedium: body,
        bodySmall: caption,
        labelLarge: button,
        labelMedium: label,
      );
}

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFAF101A);
  static const Color primaryDark = Color(0xFF8C0F19);

  static const Color background = Color(0xFFF4F6F5);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1A1D1E);
  static const Color textSecondary = Color(0xFF5B6366);

  static const Color border = Color(0xFFE2E6E4);

  static const Color critical = Color(0xFFC0152F);
  static const Color warning = Color(0xFFE0902C);
  static const Color success = Color(0xFF2E9E5B);

  static const Color lightPink = Color(0xFFF6DDE1);
  static const Color lightGreen = Color(0xFFE3F5EA);
  static const Color lightAmber = Color(0xFFFBEBD7);
  static const Color lightBlue = Color(0xFFE0EAFB);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment(0.2, 0.0),
    end: Alignment(1.0, 1.0),
    colors: [Color(0xFFAF101A), Color(0xFF6B0C12)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment(-0.5, -0.8),
    end: Alignment(1.0, 1.0),
    colors: [Color(0xFFC21A26), Color(0xFF8C0F19)],
  );

  static const Color white = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x1A000000);

  static const Color sidebarBg = Color(0xFF1A1D1E);
  static const Color sidebarText = Color(0xFFB8BEC0);
}

import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Central place for the handful of text styles used across the admin
/// app. Screens should reach for these instead of hand-rolling a
/// TextStyle so the whole app can be re-tuned from one place.
class AppTextStyles {
  AppTextStyles._();

  /// Big screen title, e.g. "Overview", "Campaigns", "Users".
  static const TextStyle screenTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// One-line description under a screen title.
  static const TextStyle screenSubtitle = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  /// Section heading within a screen, e.g. "Status Breakdown".
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// The large number on a stat card. Color varies per card.
  static TextStyle cardValue(Color color) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: color,
      );

  /// The label under a stat card's value.
  static const TextStyle cardLabel = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  /// Emphasized body text, e.g. a name in a list row.
  static const TextStyle bodyBold = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Small supporting text, e.g. metadata under a list row.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}

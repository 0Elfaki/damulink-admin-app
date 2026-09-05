import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// The standard surface card used throughout the admin app: white
/// background, 16px corners, and the shared subtle shadow. Every screen
/// used to build this by hand with slightly different numbers -- this
/// is the one place that recipe lives now.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  /// Optional extra border, e.g. a colored left accent strip. Combined
  /// with the card's normal (borderless) look when omitted.
  final BoxBorder? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.border,
  });

  static const BorderRadius radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: border,
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: child,
    );
  }
}

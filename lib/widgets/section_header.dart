import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

/// A screen title with an optional one-line subtitle underneath, e.g.
/// "Overview" / "Live numbers across the whole DamuLink platform."
/// Previously duplicated inline on the Dashboard and Staff Overview
/// screens.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.screenTitle),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: AppTextStyles.screenSubtitle),
        ],
      ],
    );
  }
}

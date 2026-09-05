import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';

/// A KPI tile: an icon chip, a big number, and a label underneath.
/// Used on the Dashboard and Staff Overview screens -- previously each
/// screen defined its own near-identical copy of this.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(value, style: AppTextStyles.cardValue(color)),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.cardLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

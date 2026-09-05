import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// The "nothing here yet" block shown in list screens once loading
/// finishes with zero results. Previously duplicated in every list
/// screen as a Padding(vertical: 60) + Center + Text.
class EmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;

  const EmptyState({super.key, required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 36, color: AppColors.textSecondary),
              const SizedBox(height: 8),
            ],
            Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

/// The loading spinner block shown while a list screen's first fetch
/// is in flight. Previously duplicated alongside [EmptyState] in every
/// list screen.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme.dart';

/// Title row plus the live-marketplace chip, kept on a tight rhythm.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'Buy & sell businesses',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: charcoal,
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: deepGreen,
                minimumSize: const Size(AppSpacing.tap, AppSpacing.tap),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onViewAll,
              child: const Text(
                'View all',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: deepGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: deepGreen),
              SizedBox(width: 6),
              Text(
                'Live marketplace',
                style: TextStyle(
                  color: deepGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

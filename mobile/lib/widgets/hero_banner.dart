import 'package:flutter/material.dart';

import '../theme.dart';

/// Gold marketplace banner with a single call to action.
class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key, required this.onListCompany});

  final VoidCallback onListCompany;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: gold,
        borderRadius: BorderRadius.circular(AppSpacing.heroRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRUSTED FILING PARTNER',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: deepGreen,
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'List your company for serious buyers',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: deepGreen,
              fontSize: 22,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Simple discovery · secure contact · fast deals',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: charcoal, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: deepGreen,
              foregroundColor: gold,
              minimumSize: const Size(AppSpacing.tap, 44),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onListCompany,
            child: const Text(
              'List your company',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/application/account_controller.dart';
import '../../registry/application/registry_submissions_controller.dart';
import '../../registry/data/registry_submission.dart';

class SellHubScreen extends ConsumerWidget {
  const SellHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountControllerProvider);
    final submissions = ref.watch(registrySubmissionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sell'),
        automaticallyImplyLeading: false,
      ),
      body: account == null
          ? _SignedOut(onSignIn: () => context.goNamed(AppRoutes.login))
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(registrySubmissionsProvider.notifier).reload(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.screen),
                children: [
                  Text(
                    'Companies submitted from Registry CIN',
                    style: AppTypography.section(),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'New submissions stay Unverified until they are reviewed.',
                    style: AppTypography.bodySmall(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...submissions.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return [
                          Text(
                            'No companies yet. Open Registry CIN to add one.',
                            style: AppTypography.bodySmall(),
                          ),
                        ];
                      }
                      return [
                        for (final item in items) _SubmissionCard(item: item),
                      ];
                    },
                    loading: () => const [
                      Padding(
                        padding: EdgeInsets.only(top: AppSpacing.lg),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                    error: (error, _) => [
                      Text(
                        error is ApiException
                            ? error.message
                            : 'Could not load your submissions.',
                        style: AppTypography.body(color: AppColors.error),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({required this.item});

  final RegistrySubmission item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.companyName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  item.companyTypeLabel.isEmpty
                      ? item.companyType
                      : item.companyTypeLabel,
                  style: AppTypography.caption(),
                ),
                if (item.cin != null && item.cin!.isNotEmpty)
                  Text('CIN ${item.cin}', style: AppTypography.caption()),
                Text(
                  item.location,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const _StatusChip(status: 'Unverified'),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.underReview.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: AppTypography.captionSmall(
          color: AppColors.underReview,
        ).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SignedOut extends StatelessWidget {
  const _SignedOut({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screen),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sign in to see companies you submitted.',
            textAlign: TextAlign.center,
            style: AppTypography.body(),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onSignIn, child: const Text('Sign in')),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/application/account_controller.dart';

/// Landing after an account is created or a user logs in.
class AppHomeScreen extends ConsumerWidget {
  const AppHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountControllerProvider);
    final roleLabel = switch (account?.role) {
      UserRole.seller => 'Seller Account',
      UserRole.buyer => 'Buyer Account',
      null => 'LinksBridge',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome',
                style: AppTypography.body(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                account?.name.isNotEmpty == true
                    ? account!.name
                    : 'LinksBridge',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.title(),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                roleLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

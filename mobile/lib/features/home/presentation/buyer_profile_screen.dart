import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/application/account_controller.dart';

class BuyerProfileScreen extends ConsumerStatefulWidget {
  const BuyerProfileScreen({super.key});

  @override
  ConsumerState<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends ConsumerState<BuyerProfileScreen> {
  var _checking = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAccount();
  }

  Future<void> _loadSavedAccount() async {
    if (ref.read(accountControllerProvider) != null) {
      if (mounted) setState(() => _checking = false);
      return;
    }
    final saved = await AccountStore.instance.read();
    if (!mounted) return;
    if (saved != null) {
      ref.read(accountControllerProvider.notifier).restore(saved);
    }
    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.lg,
            AppSpacing.screen,
            AppSpacing.md,
          ),
          child: _checking && account == null
              ? const Center(child: CircularProgressIndicator())
              : account == null
              ? _SignedOut(onSignIn: () => context.goNamed(AppRoutes.login))
              : _AccountDetails(
                  account: account,
                  onEdit: () => context.pushNamed(AppRoutes.editProfile),
                  onSignOut: () async {
                    await ref
                        .read(accountControllerProvider.notifier)
                        .signOut();
                    if (!context.mounted) return;
                    context.goNamed(AppRoutes.login);
                  },
                ),
        ),
      ),
    );
  }
}

class _AccountDetails extends StatelessWidget {
  const _AccountDetails({
    required this.account,
    required this.onEdit,
    required this.onSignOut,
  });

  final AppAccount account;
  final VoidCallback onEdit;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final contact = account.contact.trim();

    return Column(
      children: [
        Text('Profile', style: AppTypography.section()),
        const SizedBox(height: AppSpacing.lg),
        CircleAvatar(
          radius: 40,
          backgroundColor: const Color(0xFFE8EEF9),
          child: Text(
            _initials(account.name),
            style: AppTypography.title(color: const Color(0xFF1E3A8A)),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          account.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTypography.title(),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text('Details from your account', style: AppTypography.bodySmall()),
        const SizedBox(height: AppSpacing.lg),
        _DetailRow(
          icon: Icons.person_outline,
          label: 'Full name',
          value: account.name,
        ),
        const SizedBox(height: AppSpacing.sm),
        _DetailRow(
          icon: Icons.phone_outlined,
          label: 'Mobile',
          value: account.mobile.trim().isNotEmpty
              ? account.mobile
              : (contact.contains('@')
                    ? '—'
                    : (contact.isEmpty ? '—' : contact)),
        ),
        const SizedBox(height: AppSpacing.sm),
        _DetailRow(
          icon: Icons.mail_outline,
          label: 'Email',
          value: account.email.trim().isNotEmpty
              ? account.email
              : (contact.contains('@') ? contact : '—'),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.minTouch,
          child: OutlinedButton.icon(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit profile'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.minTouch,
          child: OutlinedButton.icon(
            onPressed: () {
              onSignOut();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: Color(0xFFF3C7C4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Sign out'),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.captionSmall()),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignedOut extends StatelessWidget {
  const _SignedOut({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Profile', style: AppTypography.section()),
        const Spacer(),
        Text(
          'Create an account to see your details here.',
          textAlign: TextAlign.center,
          style: AppTypography.body(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.minTouch,
          child: FilledButton(
            onPressed: onSignIn,
            child: const Text('Sign in'),
          ),
        ),
      ],
    );
  }
}

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty);
  final letters = parts.take(2).map((part) => part[0]).join();
  return letters.isEmpty ? 'A' : letters.toUpperCase();
}

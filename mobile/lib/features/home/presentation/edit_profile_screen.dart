import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../data/marketplace_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/application/account_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  var _obscureCurrent = true;
  var _obscureNew = true;
  var _obscureConfirm = true;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final account = ref.read(accountControllerProvider);
    _name.text = account?.name ?? '';
    _contact.text = account?.contact ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final mobile = _contact.text.trim();
    try {
      final user = await MarketplaceApi().updateProfile(
        name: _name.text.trim(),
        mobile: mobile,
        currentPassword: _currentPassword.text,
        password: _newPassword.text,
      );
      if (user == null) {
        throw ApiException(500, 'The server did not return your account.');
      }
      await ref
          .read(accountControllerProvider.notifier)
          .signIn(AppAccount.fromApi(user));
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.message;
      });
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit profile'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.goNamed(AppRoutes.profile);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        top: false,
        child: account == null
            ? Center(
                child: Text(
                  'Sign in again to edit your account.',
                  style: AppTypography.body(color: AppColors.textSecondary),
                ),
              )
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.sm,
                    AppSpacing.screen,
                    AppSpacing.lg,
                  ),
                  children: [
                    Text(
                      'Update the details from your account.',
                      style: AppTypography.body(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _name,
                      hint: 'Full name',
                      icon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: _contact,
                      hint: 'Mobile Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Update password', style: AppTypography.section()),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Leave these empty if you only want to change your name or contact.',
                      style: AppTypography.bodySmall(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: _currentPassword,
                      hint: 'Current password',
                      icon: Icons.lock_outline,
                      obscureText: _obscureCurrent,
                      textInputAction: TextInputAction.next,
                      suffix: IconButton(
                        tooltip: _obscureCurrent
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: _newPassword,
                      hint: 'New password',
                      icon: Icons.lock_outline,
                      obscureText: _obscureNew,
                      textInputAction: TextInputAction.next,
                      suffix: IconButton(
                        tooltip: _obscureNew
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      controller: _confirmPassword,
                      hint: 'Confirm new password',
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (_newPassword.text.isEmpty) return null;
                        if (value == null || value.isEmpty) {
                          return 'Confirm your new password';
                        }
                        if (value != _newPassword.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      suffix: IconButton(
                        tooltip: _obscureConfirm
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _error!,
                        style: AppTypography.bodySmall(color: AppColors.error),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: _saving ? 'Saving...' : 'Save changes',
                      onPressed: _saving
                          ? null
                          : () {
                              _save();
                            },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

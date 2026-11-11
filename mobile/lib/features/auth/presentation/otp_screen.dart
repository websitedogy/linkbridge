import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/marketplace_api.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/account_controller.dart';
import '../application/auth_copy.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otp = TextEditingController();
  var _busy = false;
  var _resending = false;
  String? _error;

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_busy) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      final user = await MarketplaceApi().verifyOtp(
        email: widget.email,
        otp: _otp.text.trim(),
      );
      if (user == null) {
        throw ApiException(500, 'The server did not return your account.');
      }
      await ref
          .read(accountControllerProvider.notifier)
          .signIn(AppAccount.fromApi(user));
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = AuthCopy.loginError(error);
        _busy = false;
      });
      return;
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Could not reach the server. Please try again.';
        _busy = false;
      });
      return;
    }
    if (!mounted) {
      return;
    }
    context.goNamed(AppRoutes.home);
  }

  Future<void> _resend() async {
    if (_resending || widget.email.isEmpty) {
      return;
    }
    setState(() {
      _error = null;
      _resending = true;
    });
    try {
      await MarketplaceApi().resendOtp(email: widget.email);
      if (!mounted) {
        return;
      }
      setState(() => _resending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP sent to your email')));
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.message;
        _resending = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Could not reach the server. Please try again.';
        _resending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }
            context.goNamed(AppRoutes.login);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.xs,
            AppSpacing.screen,
            AppSpacing.md,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verify your email', style: AppTypography.title()),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Enter the 6-digit code we sent to ${widget.email}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _otp,
                  hint: '6-digit OTP',
                  icon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _verify(),
                  validator: (value) {
                    if (value == null || value.trim().length != 6) {
                      return 'Enter the 6-digit OTP';
                    }
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _error!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Verify OTP',
                  busy: _busy,
                  onPressed: _verify,
                ),
                const SizedBox(height: AppSpacing.xs),
                Center(
                  child: TextButton(
                    onPressed: _resending ? null : _resend,
                    child: Text(_resending ? 'Sending...' : 'Resend OTP'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

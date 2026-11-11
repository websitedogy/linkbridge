import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/application/account_controller.dart';
import '../../home/data/buyer_mock.dart';
import '../application/registry_submissions_controller.dart';
import '../data/detected_location.dart';
import '../data/location_detector.dart';

class RegistryCinScreen extends ConsumerStatefulWidget {
  const RegistryCinScreen({super.key});

  @override
  ConsumerState<RegistryCinScreen> createState() => _RegistryCinScreenState();
}

class _RegistryCinScreenState extends ConsumerState<RegistryCinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyName = TextEditingController();
  final _cin = TextEditingController();
  final _directorContact = TextEditingController();
  final _directorEmail = TextEditingController();
  final _detector = LocationDetector();

  String? _companyType;
  DetectedLocation? _location;
  var _locating = true;
  var _busy = false;
  String? _locationError;
  String? _error;

  static final _cinPattern = RegExp(
    r'^[A-Z]{1}[0-9]{5}[A-Z]{2}[0-9]{4}[A-Z]{3}[0-9]{6}$',
  );
  static final _mobilePattern = RegExp(r'^[6-9][0-9]{9}$');

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  @override
  void dispose() {
    _companyName.dispose();
    _cin.dispose();
    _directorContact.dispose();
    _directorEmail.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() {
      _locating = true;
      _locationError = null;
    });
    try {
      final location = await _detector.detect();
      if (!mounted) {
        return;
      }
      setState(() {
        _location = location;
        _locating = false;
      });
    } on LocationDetectException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _locationError = error.message;
        _locating = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _locationError = 'Could not detect your current location. Try again.';
        _locating = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    if (ref.read(accountControllerProvider) == null) {
      context.goNamed(AppRoutes.login);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final companyType = _companyType;
    final location = _location;
    if (companyType == null) {
      return;
    }
    if (location == null) {
      setState(() {
        _error = _locationError ?? 'Wait for location to be detected.';
      });
      return;
    }

    final cin = _cin.text.trim().toUpperCase();
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      await ref
          .read(registrySubmissionsProvider.notifier)
          .submit(
            companyType: companyType,
            companyName: _companyName.text.trim(),
            cin: cin.isEmpty ? null : cin,
            directorContact: _directorContact.text.replaceAll(
              RegExp(r'\D'),
              '',
            ),
            directorEmail: _directorEmail.text.trim(),
            location: location.label,
            latitude: location.latitude,
            longitude: location.longitude,
          );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.status == 401
            ? 'Please sign in to submit this form.'
            : error.message;
        _busy = false;
      });
      if (error.status == 401) {
        context.goNamed(AppRoutes.login);
      }
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submitted. Status is Unverified.')),
    );
    context.goNamed(AppRoutes.sellTab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registry CIN'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        top: false,
        child: Form(
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
                'Enter company details. After submit they appear on Sell as Unverified.',
                style: AppTypography.body(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<String>(
                initialValue: _companyType,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Company Type',
                  prefixIcon: Icon(Icons.apartment_outlined),
                ),
                items: [
                  for (final type in BuyerMock.companyTypes)
                    DropdownMenuItem(value: type.id, child: Text(type.label)),
                ],
                onChanged: (value) => setState(() => _companyType = value),
                validator: (value) =>
                    value == null ? 'Select a company type' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _companyName,
                hint: 'Company Name',
                icon: Icons.business_outlined,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _cin,
                textCapitalization: TextCapitalization.characters,
                maxLength: 21,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  _UpperCaseFormatter(),
                ],
                style: AppTypography.body(),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'CIN no. (optional)',
                  counterText: '',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  final cin = value?.trim().toUpperCase() ?? '';
                  if (cin.isEmpty) {
                    return null;
                  }
                  if (!_cinPattern.hasMatch(cin)) {
                    return 'Enter a valid 21-character CIN, or leave it blank';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _directorContact,
                hint: 'Director contact number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final mobile = (value ?? '').replaceAll(RegExp(r'\D'), '');
                  if (!_mobilePattern.hasMatch(mobile)) {
                    return 'Enter a valid 10-digit mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _directorEmail,
                hint: 'Director Mail id',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty || !email.contains('@')) {
                    return 'Enter a valid director mail id';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _LocationCard(
                locating: _locating,
                location: _location?.label,
                error: _locationError,
                onRetry: _detectLocation,
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!, style: AppTypography.body(color: AppColors.error)),
              ],
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Submit',
                busy: _busy,
                onPressed: _locating ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.locating,
    required this.onRetry,
    this.location,
    this.error,
  });

  final bool locating;
  final String? location;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.my_location, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current location', style: AppTypography.section()),
                const SizedBox(height: AppSpacing.xxs),
                if (locating)
                  Text(
                    'Detecting your location…',
                    style: AppTypography.bodySmall(),
                  )
                else if (location != null)
                  Text(location!, style: AppTypography.body())
                else
                  Text(
                    error ?? 'Location not available',
                    style: AppTypography.body(color: AppColors.error),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh location',
            onPressed: locating ? null : onRetry,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

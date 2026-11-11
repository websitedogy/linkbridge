import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/application/account_controller.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/listings_controller.dart';
import '../data/buyer_mock.dart';

class ListingPrefill {
  const ListingPrefill({
    this.cin,
    this.name,
    this.location,
    this.companyTypeId,
    this.description,
  });

  final String? cin;
  final String? name;
  final String? location;
  final String? companyTypeId;
  final String? description;
}

class SellCompanyScreen extends ConsumerStatefulWidget {
  const SellCompanyScreen({super.key, this.prefill, this.embedded = false});

  final ListingPrefill? prefill;
  final bool embedded;

  @override
  ConsumerState<SellCompanyScreen> createState() => _SellCompanyScreenState();
}

class _SellCompanyScreenState extends ConsumerState<SellCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  String? _industry;
  String? _companyType;

  @override
  void initState() {
    super.initState();
    final prefill = widget.prefill;
    if (prefill == null) return;
    _name.text = prefill.name ?? '';
    _location.text = prefill.location ?? '';
    _description.text = prefill.description ?? '';
    _companyType = prefill.companyTypeId;
  }

  static const _industries = [
    'Technology',
    'Manufacturing',
    'Retail',
    'Healthcare',
    'Construction',
  ];

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  void _post() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final industry = _industry;
    final companyType = _companyType;
    if (industry == null || companyType == null) return;
    final account = ref.read(accountControllerProvider);
    ref
        .read(listingsProvider.notifier)
        .post(
          BuyerListing(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _name.text.trim(),
            location: _location.text.trim(),
            tags: [industry],
            askingPrice: _price.text.trim(),
            revenue: 'On request',
            employees: '—',
            imageUrl: _imageFor(industry),
            companyType: companyType,
            sellerName: account?.name.isNotEmpty == true
                ? account!.name
                : 'You',
            description: _description.text.trim(),
            mine: true,
          ),
        );
    if (widget.embedded || !context.canPop()) {
      context.goNamed(AppRoutes.home);
      return;
    }
    context.pop();
  }

  String _imageFor(String industry) {
    return switch (industry) {
      'Manufacturing' => AppAssets.workshop,
      'Retail' => AppAssets.retail,
      'Healthcare' => AppAssets.clinic,
      'Construction' => AppAssets.construction,
      _ => AppAssets.office,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sell a company'),
        automaticallyImplyLeading: !widget.embedded,
        leading: widget.embedded
            ? const SizedBox.shrink()
            : IconButton(
                tooltip: 'Back',
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                    return;
                  }
                  context.goNamed(AppRoutes.home);
                },
                icon: const Icon(Icons.arrow_back),
              ),
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
                'Add your company details. It shows on the same marketplace for everyone.',
                style: AppTypography.body(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<String>(
                initialValue: _companyType,
                decoration: const InputDecoration(
                  hintText: 'Company type',
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
                controller: _name,
                hint: 'Company name',
                icon: Icons.apartment_outlined,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _industry,
                decoration: const InputDecoration(
                  hintText: 'Industry',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: [
                  for (final industry in _industries)
                    DropdownMenuItem(value: industry, child: Text(industry)),
                ],
                onChanged: (value) => setState(() => _industry = value),
                validator: (value) =>
                    value == null ? 'Select an industry' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _location,
                hint: 'City, location',
                icon: Icons.location_on_outlined,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _price,
                hint: 'Asking price (e.g. ₹12 Cr)',
                icon: Icons.currency_rupee,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the asking price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _description,
                minLines: 4,
                maxLines: 6,
                style: AppTypography.body(),
                decoration: const InputDecoration(
                  hintText:
                      'Describe the company, revenue, and why you are selling',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Add a short description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(label: 'Post listing', onPressed: _post),
            ],
          ),
        ),
      ),
    );
  }
}

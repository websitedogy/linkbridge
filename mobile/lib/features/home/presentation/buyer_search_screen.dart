import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../data/buyer_mock.dart';
import '../widgets/listing_card.dart';

class BuyerSearchScreen extends StatefulWidget {
  const BuyerSearchScreen({super.key});

  @override
  State<BuyerSearchScreen> createState() => _BuyerSearchScreenState();
}

class _BuyerSearchScreenState extends State<BuyerSearchScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _query.text.trim().toLowerCase();
    final results = BuyerMock.listings.where((listing) {
      if (text.isEmpty) return true;
      final haystack =
          '${listing.title} ${listing.location} ${listing.tags.join(' ')}'
              .toLowerCase();
      return haystack.contains(text);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.sm,
              ),
              child: TextField(
                controller: _query,
                onChanged: (_) => setState(() {}),
                style: AppTypography.body(),
                decoration: InputDecoration(
                  hintText: 'Search businesses, industry, location...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: IconButton(
                    tooltip: 'Filter',
                    onPressed: () {},
                    icon: const Icon(Icons.tune, color: AppColors.textPrimary),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        'No businesses found',
                        style: AppTypography.bodySmall(),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        0,
                        AppSpacing.screen,
                        AppSpacing.lg,
                      ),
                      itemCount: results.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) =>
                          ListingCard(listing: results[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

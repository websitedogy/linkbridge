import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/listings_controller.dart';
import '../widgets/listing_card.dart';

class MyAdsScreen extends ConsumerWidget {
  const MyAdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = ref
        .watch(listingsProvider)
        .where((listing) => listing.mine)
        .toList();
    final saved = ref.watch(savedListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My ads')),
      body: mine.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No companies posted yet',
                    style: AppTypography.section(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Post your company details and it will show up in the marketplace.',
                    style: AppTypography.bodySmall(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Sell a company',
                    onPressed: () => context.pushNamed(AppRoutes.sell),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screen),
              itemCount: mine.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final listing = mine[index];
                return ListingCard(
                  listing: listing,
                  saved: saved.contains(listing.id),
                  onHeart: () => ref
                      .read(savedListingsProvider.notifier)
                      .toggle(listing.id),
                  onOpen: () => context.pushNamed(
                    AppRoutes.listing,
                    pathParameters: {'id': listing.id},
                  ),
                );
              },
            ),
    );
  }
}

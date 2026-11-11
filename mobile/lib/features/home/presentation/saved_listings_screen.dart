import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../application/listings_controller.dart';
import '../widgets/listing_card.dart';

class SavedListingsScreen extends ConsumerWidget {
  const SavedListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedListingsProvider);
    final listings = ref
        .watch(listingsProvider)
        .where((listing) => saved.contains(listing.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Saved')),
      body: listings.isEmpty
          ? Center(
              child: Text(
                'No saved companies yet',
                style: AppTypography.bodySmall(),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screen),
              itemCount: listings.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final listing = listings[index];
                return ListingCard(
                  listing: listing,
                  saved: true,
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

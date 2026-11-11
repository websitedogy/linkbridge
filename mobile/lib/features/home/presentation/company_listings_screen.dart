import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../application/listings_controller.dart';
import '../data/buyer_mock.dart';
import '../widgets/listing_card.dart';

class CompanyListingsScreen extends ConsumerWidget {
  const CompanyListingsScreen({super.key, required this.typeId});

  final String typeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = BuyerMock.companyTypes
        .where((item) => item.id == typeId)
        .firstOrNull;
    final saved = ref.watch(savedListingsProvider);
    final listings = ref
        .watch(listingsProvider)
        .where((listing) => listing.companyType == typeId)
        .toList();
    final title = type?.label ?? 'Companies';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: IconButton(
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
      body: listings.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'No $title companies are listed for sale yet.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall(),
                ),
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

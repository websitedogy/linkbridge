import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/listings_controller.dart';
import '../data/buyer_mock.dart';

class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(
      listingsProvider.select((items) {
        for (final item in items) {
          if (item.id == id) return item;
        }
        return null;
      }),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Company'),
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
      body: listing == null
          ? Center(
              child: Text(
                'This listing is no longer available',
                style: AppTypography.bodySmall(),
              ),
            )
          : _Detail(listing: listing),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.listing});

  final BuyerListing listing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.lg,
            ),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: listing.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        const ColoredBox(color: AppColors.surface),
                    errorWidget: (_, _, _) =>
                        const ColoredBox(color: AppColors.surface),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(listing.title, style: AppTypography.title()),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                listing.askingPrice,
                style: AppTypography.section(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      listing.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in listing.tags)
                    Chip(
                      label: Text(
                        tag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: AppColors.surface,
                      side: BorderSide.none,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text('About this company', style: AppTypography.section()),
              const SizedBox(height: AppSpacing.xs),
              Text(listing.description, style: AppTypography.body()),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Listed by ${listing.sellerName}',
                style: AppTypography.bodySmall(),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.xs,
              AppSpacing.screen,
              AppSpacing.md,
            ),
            child: PrimaryButton(
              label: listing.mine ? 'Your listing' : 'Contact seller',
              onPressed: listing.mine
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Message sent to ${listing.sellerName}',
                          ),
                        ),
                      );
                    },
            ),
          ),
        ),
      ],
    );
  }
}

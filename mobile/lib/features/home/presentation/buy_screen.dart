import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../application/listings_controller.dart';
import '../widgets/listing_card.dart';

class BuyScreen extends ConsumerStatefulWidget {
  const BuyScreen({super.key, this.initialQuery = '', this.initialIndustry});

  final String initialQuery;
  final String? initialIndustry;

  @override
  ConsumerState<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends ConsumerState<BuyScreen> {
  late final TextEditingController _query = TextEditingController(
    text: widget.initialQuery,
  );
  late String? _industry = widget.initialIndustry;
  var _segment = 0;

  static const _filters = [
    'Technology',
    'Manufacturing',
    'Retail',
    'Healthcare',
    'Construction',
  ];

  @override
  void didUpdateWidget(BuyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != oldWidget.initialQuery &&
        _query.text != widget.initialQuery) {
      _query.text = widget.initialQuery;
    }
    if (widget.initialIndustry != oldWidget.initialIndustry) {
      _industry = widget.initialIndustry;
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(listingsProvider);
    final saved = ref.watch(savedListingsProvider);
    final interested = ref.watch(interestedListingsProvider);
    final query = _query.text.trim().toLowerCase();

    final visible = listings.where((listing) {
      if (_segment == 1 && !saved.contains(listing.id)) return false;
      if (_segment == 2 && !interested.contains(listing.id)) return false;
      if (_industry != null && !listing.tags.contains(_industry)) return false;
      if (query.isEmpty) return true;
      final haystack =
          '${listing.title} ${listing.location} ${listing.tags.join(' ')}'
              .toLowerCase();
      return haystack.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Buy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.xs,
          AppSpacing.screen,
          AppSpacing.lg,
        ),
        children: [
          TextField(
            controller: _query,
            style: AppTypography.body(),
            decoration: const InputDecoration(
              hintText: 'Search businesses',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final (index, label) in const [
                  (0, 'All businesses'),
                  (1, 'Saved'),
                  (2, 'My Interests'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _segment == index,
                      onSelected: (_) => setState(() => _segment = index),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: FilterChip(
                    label: const Text('All industries'),
                    selected: _industry == null,
                    onSelected: (_) => setState(() => _industry = null),
                  ),
                ),
                for (final filter in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _industry == filter,
                      onSelected: (_) => setState(
                        () => _industry = _industry == filter ? null : filter,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: Text(
                _segment == 1
                    ? 'No saved businesses yet.'
                    : _segment == 2
                    ? 'No interests yet. Mark a listing as interested.'
                    : 'No businesses match these filters.',
                style: AppTypography.bodySmall(),
              ),
            )
          else
            for (final listing in visible) ...[
              ListingCard(
                listing: listing,
                saved: saved.contains(listing.id),
                onHeart: () =>
                    ref.read(savedListingsProvider.notifier).toggle(listing.id),
                onOpen: () => context.pushNamed(
                  AppRoutes.listing,
                  pathParameters: {'id': listing.id},
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => ref
                      .read(interestedListingsProvider.notifier)
                      .toggle(listing.id),
                  child: Text(
                    interested.contains(listing.id)
                        ? 'Interested'
                        : 'Mark interest',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
        ],
      ),
    );
  }
}

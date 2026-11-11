import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/application/account_controller.dart';
import '../application/listings_controller.dart';
import '../data/buyer_mock.dart';

class BuyerDashboardScreen extends ConsumerStatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  ConsumerState<BuyerDashboardScreen> createState() =>
      _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends ConsumerState<BuyerDashboardScreen> {
  final _hero = PageController();
  var _heroPage = 0;

  static const _slides = [
    (
      kicker: 'BUSINESSES FOR SALE',
      title: 'Companies for sale',
      subtitle: 'Browse LLP, Pvt Ltd, OPC and more in one marketplace.',
      image: AppAssets.tower,
    ),
    (
      kicker: 'VERIFIED LISTINGS',
      title: 'Serious buyers, ready sellers',
      subtitle: 'Compare price, revenue, and location before you enquire.',
      image: AppAssets.office,
    ),
    (
      kicker: 'ONE MARKETPLACE',
      title: 'Sell your company',
      subtitle: 'Post company details and reach buyers on the same feed.',
      image: AppAssets.workshop,
    ),
  ];

  @override
  void dispose() {
    _hero.dispose();
    super.dispose();
  }

  void _openBuy() => context.goNamed(AppRoutes.buy);

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(listingsProvider);
    final account = ref.watch(accountControllerProvider);
    final saved = ref.watch(savedListingsProvider);
    final featured = listings
        .where((listing) => !listing.mine)
        .take(2)
        .toList();
    final recent = listings.length > 2 ? listings.sublist(2) : listings;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('LinksBridge'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
            icon: const Icon(Icons.notifications_none),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => context.goNamed(AppRoutes.profile),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFE8EEF9),
                    child: account?.name.trim().isNotEmpty == true
                        ? Text(
                            _initials(account!.name),
                            style: AppTypography.captionSmall(
                              color: const Color(0xFF1E3A8A),
                            ).copyWith(fontWeight: FontWeight.w700),
                          )
                        : const Icon(
                            Icons.person,
                            size: 16,
                            color: Color(0xFF1E3A8A),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.xs,
          AppSpacing.screen,
          AppSpacing.lg,
        ),
        children: [
          SizedBox(
            height: 228,
            child: PageView.builder(
              controller: _hero,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _heroPage = index),
              itemBuilder: (context, index) =>
                  _HeroSlide(slide: _slides[index]),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _slides.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == _heroPage ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _heroPage
                        ? AppColors.accent
                        : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle(title: 'Company types', onViewAll: () => _openBuy()),
          const SizedBox(height: 2),
          Text(
            'Tap a type to see companies listed for sale.',
            style: AppTypography.caption(),
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: BuyerMock.companyTypes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.15,
            ),
            itemBuilder: (context, index) {
              final type = BuyerMock.companyTypes[index];
              final count = listings
                  .where((listing) => listing.companyType == type.id)
                  .length;
              return _TypeTile(
                label: type.id == 'section-8' ? 'Section 8' : type.label,
                count: count,
                icon: type.icon,
                color: type.color,
                background: type.background,
                onTap: () => context.pushNamed(
                  AppRoutes.companies,
                  queryParameters: {'type': type.id},
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle(
            title: 'Featured Companies',
            onViewAll: () => _openBuy(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < featured.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: _FeaturedCard(
                    listing: featured[i],
                    saved: saved.contains(featured[i].id),
                    onHeart: () => ref
                        .read(savedListingsProvider.notifier)
                        .toggle(featured[i].id),
                    onOpen: () => context.pushNamed(
                      AppRoutes.listing,
                      pathParameters: {'id': featured[i].id},
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle(title: 'Recently Added', onViewAll: () => _openBuy()),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recent.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final listing = recent[index];
                return _RecentCard(
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
          ),
        ],
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  const _HeroSlide({required this.slide});

  final ({String kicker, String title, String subtitle, String image}) slide;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: slide.image,
            fit: BoxFit.cover,
            placeholder: (_, _) => const ColoredBox(color: Color(0xFF1D4ED8)),
            errorWidget: (_, _, _) =>
                const ColoredBox(color: Color(0xFF1D4ED8)),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xE61E3A8A), Color(0xB32F6BFF)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.kicker,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionSmall(
                    color: Colors.white.withValues(alpha: 0.85),
                  ).copyWith(letterSpacing: 0.6, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  slide.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  slide.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.section(),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            visualDensity: VisualDensity.compact,
            textStyle: AppTypography.caption(
              color: AppColors.accent,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          child: const Text('View All'),
        ),
      ],
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selling = count == 1 ? '1 for sale' : '$count for sale';
    return Material(
      color: AppColors.background,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.soft,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption(
                          color: AppColors.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        selling,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.captionSmall(),
                      ),
                    ],
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

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.listing,
    required this.saved,
    required this.onHeart,
    required this.onOpen,
  });

  final BuyerListing listing;
  final bool saved;
  final VoidCallback onHeart;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final badge = listing.tags.isEmpty ? 'Listed' : listing.tags.first;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 92,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: listing.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) =>
                            const ColoredBox(color: AppColors.surface),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _Heart(saved: saved, onTap: onHeart),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6EE),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        badge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.captionSmall(
                          color: AppColors.featured,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption(
                        color: AppColors.textPrimary,
                      ).copyWith(fontWeight: FontWeight.w700, height: 1.25),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            listing.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.captionSmall(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      listing.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.captionSmall(
                        color: AppColors.textSecondary,
                      ).copyWith(height: 1.35),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _Stat(
                            label: 'Asking Price',
                            value: listing.askingPrice,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _Stat(
                            label: 'Annual Revenue',
                            value: listing.revenue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.captionSmall(),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.captionSmall(
            color: AppColors.textPrimary,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({
    required this.listing,
    required this.saved,
    required this.onHeart,
    required this.onOpen,
  });

  final BuyerListing listing;
  final bool saved;
  final VoidCallback onHeart;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onOpen,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    height: 84,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: listing.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) =>
                              const ColoredBox(color: AppColors.surface),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: _Heart(saved: saved, onTap: onHeart),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.captionSmall(
                          color: AppColors.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w700, height: 1.25),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        listing.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.captionSmall(),
                      ),
                    ],
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

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty);
  return parts.take(2).map((part) => part[0]).join().toUpperCase();
}

class _Heart extends StatelessWidget {
  const _Heart({required this.saved, required this.onTap});

  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 26,
          height: 26,
          child: Icon(
            saved ? Icons.favorite : Icons.favorite_border,
            size: 15,
            color: const Color(0xFFE11D48),
          ),
        ),
      ),
    );
  }
}

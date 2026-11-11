import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/session.dart';
import '../theme.dart';
import '../widgets/category_card.dart';
import '../widgets/hero_banner.dart';
import '../widgets/section_header.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _keyword = TextEditingController();
  bool _searchOpen = false;
  List<String> _cities = const [];

  static const _categories = <({String title, String count, IconData icon})>[
    (title: 'LLP', count: '4 companies', icon: Icons.home_outlined),
    (title: 'Pvt Ltd', count: '14 companies', icon: Icons.work_outline),
    (title: 'OPC', count: '4 companies', icon: Icons.person_outline),
    (
      title: 'Section 8 Company',
      count: '4 companies',
      icon: Icons.shield_outlined,
    ),
    (
      title: 'Nidhi Company',
      count: '4 companies',
      icon: Icons.account_balance_wallet_outlined,
    ),
    (
      title: 'Producer Company',
      count: '4 companies',
      icon: Icons.inventory_2_outlined,
    ),
    (
      title: 'Partnership',
      count: '4 companies',
      icon: Icons.handshake_outlined,
    ),
    (
      title: 'Proprietorship',
      count: '4 companies',
      icon: Icons.storefront_outlined,
    ),
    (title: 'Public Ltd', count: '4 companies', icon: Icons.apartment_outlined),
  ];

  @override
  void dispose() {
    _keyword.dispose();
    super.dispose();
  }

  Future<void> _toggleSearch() async {
    setState(() => _searchOpen = !_searchOpen);
    if (!_searchOpen || _cities.isNotEmpty) {
      return;
    }
    try {
      final rows = await ref.read(apiProvider).locations('city');
      if (mounted) {
        setState(() {
          _cities = rows
              .map((row) => row['name']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
        });
      }
    } catch (_) {}
  }

  void _listCompany() {
    final signedIn = ref.read(sessionProvider).asData?.value != null;
    context.go(signedIn ? '/sale' : '/register?role=seller');
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final name = session.value?['name']?.toString();
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardRatio = (1.15 / textScale).clamp(0.85, 1.15);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Column(
        children: [
          _HomeHeader(
            name: name,
            searchOpen: _searchOpen,
            keyword: _keyword,
            cities: _cities,
            onFavorites: () => context.go('/favorites'),
            onSearch: _toggleSearch,
            onProfile: () =>
                context.go(session.value == null ? '/login' : '/profile'),
            onKeyword: (value) => context.go(
              '/buy?keyword=${Uri.encodeQueryComponent(value.trim())}',
            ),
            onCity: (city) {
              if (city == null || city.isEmpty) {
                context.go('/buy');
              } else {
                context.go('/buy?city=${Uri.encodeQueryComponent(city)}');
              }
            },
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.navClearance,
              ),
              children: [
                HeroBanner(onListCompany: _listCompany),
                const SizedBox(height: AppSpacing.md),
                SectionHeader(onViewAll: () => context.go('/buy')),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: cardRatio,
                  children: [
                    for (final category in _categories)
                      CategoryCard(
                        title: category.title,
                        subtitle: category.count,
                        icon: category.icon,
                        onTap: () => context.go(
                          '/buy?keyword=${Uri.encodeQueryComponent(category.title)}',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const _StatsRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.name,
    required this.searchOpen,
    required this.keyword,
    required this.cities,
    required this.onFavorites,
    required this.onSearch,
    required this.onProfile,
    required this.onKeyword,
    required this.onCity,
  });

  final String? name;
  final bool searchOpen;
  final TextEditingController keyword;
  final List<String> cities;
  final VoidCallback onFavorites;
  final VoidCallback onSearch;
  final VoidCallback onProfile;
  final ValueChanged<String> onKeyword;
  final ValueChanged<String?> onCity;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: deepGreen,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'L',
                      style: TextStyle(
                        color: deepGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'LinksBridge',
                            maxLines: 1,
                            style: TextStyle(
                              color: cream,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'SELL & BUY',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: gold,
                            fontSize: 11,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _HeaderIcon(
                    icon: Icons.favorite_border,
                    tooltip: 'Favorites',
                    onPressed: onFavorites,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _HeaderIcon(
                    icon: searchOpen ? Icons.close : Icons.search,
                    tooltip: searchOpen ? 'Close search' : 'Search',
                    color: searchOpen ? gold : cream,
                    onPressed: onSearch,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _ProfileAvatar(initials: _initials(name), onTap: onProfile),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: searchOpen
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Column(
                    children: [
                      TextField(
                        controller: keyword,
                        style: const TextStyle(color: charcoal),
                        decoration: InputDecoration(
                          hintText: 'Search companies, services...',
                          filled: true,
                          fillColor: cream,
                          prefixIcon: const Icon(Icons.search, color: charcoal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                          isDense: true,
                        ),
                        onSubmitted: onKeyword,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: cream,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: '',
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('All locations'),
                              ),
                              for (final city in cities)
                                DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                ),
                            ],
                            onChanged: onCity,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = cream,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: AppSpacing.icon,
      color: color,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: AppSpacing.tap,
        height: AppSpacing.tap,
      ),
      icon: Icon(icon),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initials, required this.onTap});

  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.tap,
      height: AppSpacing.tap,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Center(
          child: CircleAvatar(
            radius: 18,
            backgroundColor: gold,
            child: Text(
              initials,
              style: const TextStyle(
                color: deepGreen,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: deepGreen.withValues(alpha: 0.08)),
      ),
      child: const Row(
        children: [
          _Stat('12k+', 'Companies filed'),
          _Stat('4.8★', 'Client rating'),
          _Stat('24/7', 'Support'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: deepGreen,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: muted),
          ),
        ],
      ),
    );
  }
}

String _initials(String? name) {
  if (name == null || name.trim().isEmpty) {
    return 'LB';
  }
  final parts = name.trim().split(RegExp(r'\s+'));
  final first = parts.first.isEmpty ? '' : parts.first[0];
  final second = parts.length > 1 && parts[1].isNotEmpty
      ? parts[1][0]
      : (parts.first.length > 1 ? parts.first[1] : '');
  return ('$first$second').toUpperCase();
}

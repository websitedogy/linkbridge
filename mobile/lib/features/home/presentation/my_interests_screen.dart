import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../data/buyer_mock.dart';
import '../widgets/listing_card.dart';

class MyInterestsScreen extends StatefulWidget {
  const MyInterestsScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<MyInterestsScreen> createState() => _MyInterestsScreenState();
}

class _MyInterestsScreenState extends State<MyInterestsScreen> {
  late int _tab = widget.initialTab.clamp(0, 2);

  static const _tabs = <({String label, int count})>[
    (label: 'Saved', count: 12),
    (label: 'Interested', count: 6),
    (label: 'Inquiries', count: 4),
  ];

  @override
  Widget build(BuildContext context) {
    final items = BuyerMock.forTab(_tab);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => context.goNamed(AppRoutes.home),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      'My Interests',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTypography.section(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.minTouch),
                ],
              ),
            ),
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++)
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _tab = i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${_tabs[i].label} (${_tabs[i].count})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTypography.caption(
                                    color: i == _tab
                                        ? AppColors.accent
                                        : AppColors.textSecondary,
                                  ).copyWith(
                                    fontWeight: i == _tab
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Container(
                              height: 2,
                              color: i == _tab
                                  ? AppColors.accent
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.screen),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) =>
                    ListingCard(listing: items[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

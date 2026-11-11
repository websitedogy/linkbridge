import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  var _index = 0;

  static const _pages = [
    _OnboardingPage(
      title: 'Find the Right Business Opportunity',
      subtitle: 'Explore verified businesses across industries and locations.',
      company: 'Established IT Services Company',
      imageUrl: AppAssets.office,
    ),
    _OnboardingPage(
      title: 'Invest in Profitable Businesses',
      subtitle:
          'Compare asking price, revenue, and team size before you decide.',
      company: 'Precision Engineering Company',
      imageUrl: AppAssets.workshop,
    ),
    _OnboardingPage(
      title: 'Reach Serious Buyers',
      subtitle:
          'List your business and connect with buyers who are ready to close.',
      company: 'Established SaaS Platform',
      imageUrl: AppAssets.officeFloor,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openLogin() => context.goNamed(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.xxs,
            AppSpacing.screen,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    minimumSize: const Size(
                      AppSpacing.minTouch,
                      AppSpacing.minTouch,
                    ),
                    textStyle: AppTypography.body(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onPressed: _openLogin,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (index) => setState(() => _index = index),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          page.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.title(),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          page.subtitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Center(child: _OpportunityPreview(page: page)),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Semantics(
                label: 'Page ${_index + 1} of ${_pages.length}',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _pages.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxs,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: i == _index ? 8 : 6,
                          height: i == _index ? 8 : 6,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? AppColors.gold
                                : AppColors.border,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: 'Get Started →',
                onPressed: () => context.pushNamed(AppRoutes.createAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.company,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String company;
  final String imageUrl;
}

class _OpportunityPreview extends StatelessWidget {
  const _OpportunityPreview({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth * 0.72).clamp(160.0, 260.0);
        final cardHeight = (cardWidth * 0.78).clamp(
          120.0,
          constraints.maxHeight * 0.72,
        );
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Transform.rotate(
                angle: -0.1,
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: AppShadows.soft,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: page.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        const ColoredBox(color: AppColors.surface),
                    errorWidget: (_, _, _) => const ColoredBox(
                      color: AppColors.surface,
                      child: Icon(
                        Icons.apartment_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.xs,
                right: cardWidth * 0.18,
                bottom: constraints.maxHeight > 180 ? 12 : 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Row(
                    children: [
                      const ExcludeSemantics(
                        child: Icon(
                          Icons.bar_chart_rounded,
                          color: AppColors.featured,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          page.company,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall(
                            color: AppColors.textPrimary,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

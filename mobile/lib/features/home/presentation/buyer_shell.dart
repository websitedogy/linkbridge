import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class BuyerShell extends StatelessWidget {
  const BuyerShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: navigationShell),
        _MarketNav(
          branch: navigationShell.currentIndex,
          onBranch: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      ],
    );
  }
}

class _MarketNav extends StatelessWidget {
  const _MarketNav({required this.branch, required this.onBranch});

  final int branch;
  final ValueChanged<int> onBranch;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _Item(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  selected: branch == 0,
                  onTap: () => onBranch(0),
                ),
                _Item(
                  icon: Icons.add_business_outlined,
                  activeIcon: Icons.add_business,
                  label: 'Sell',
                  selected: branch == 1,
                  onTap: () => onBranch(1),
                ),
                _Item(
                  icon: Icons.badge_outlined,
                  activeIcon: Icons.badge,
                  label: 'Registry CIN',
                  selected: branch == 2,
                  onTap: () => onBranch(2),
                ),
                _Item(
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag,
                  label: 'Buy',
                  selected: branch == 3,
                  onTap: () => onBranch(3),
                ),
                _Item(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  selected: branch == 4,
                  onTap: () => onBranch(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: AppTypography.captionSmall(color: color).copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme.dart';

/// Five equal slots. The center slot is only the label; the raised button is the scaffold FAB.
class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: cream,
      elevation: 8,
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _Slot(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: path == '/',
                onTap: () => context.go('/'),
              ),
              _Slot(
                icon: Icons.shopping_bag_outlined,
                label: 'Sale',
                selected: path.startsWith('/sale'),
                onTap: () => context.go('/sale'),
              ),
              _Slot(
                label: 'CIN Verify',
                selected: path.startsWith('/cin-verify'),
                onTap: () => context.go('/cin-verify'),
              ),
              _Slot(
                icon: Icons.shopping_cart_outlined,
                label: 'Buy',
                selected: path.startsWith('/buy'),
                onTap: () => context.go('/buy'),
              ),
              _Slot(
                icon: Icons.link,
                label: 'Licence',
                selected: path.startsWith('/licences'),
                onTap: () => context.go('/licences'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final IconData? icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? deepGreen : muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (icon != null)
              Icon(icon, size: AppSpacing.icon, color: color)
            else
              const SizedBox(height: AppSpacing.icon),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme.dart';
import '../widgets/custom_bottom_nav.dart';
import 'extra_screens.dart';

class MarketplaceShell extends StatelessWidget {
  const MarketplaceShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;

    return Scaffold(
      backgroundColor: cream,
      // The notch tracks the scaffold FAB, so CIN owns that slot.
      // The chat button is placed above the bar instead of endFloat.
      floatingActionButton: FloatingActionButton(
        heroTag: 'linksbridge-cin',
        backgroundColor: deepGreen,
        foregroundColor: gold,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () => context.go('/cin-verify'),
        child: const Icon(Icons.description_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNav(path: path),
      body: Stack(
        children: [
          child,
          const Positioned(
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: AssistantButton(),
          ),
        ],
      ),
    );
  }
}

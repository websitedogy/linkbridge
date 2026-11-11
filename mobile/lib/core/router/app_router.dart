import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/create_account_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/home/presentation/buy_screen.dart';
import '../../features/home/presentation/buyer_dashboard_screen.dart';
import '../../features/home/presentation/edit_profile_screen.dart';
import '../../features/home/presentation/company_listings_screen.dart';
import '../../features/home/presentation/buyer_profile_screen.dart';
import '../../features/home/presentation/buyer_shell.dart';
import '../../features/home/presentation/listing_detail_screen.dart';
import '../../features/home/presentation/sell_company_screen.dart';
import '../../features/home/presentation/sell_hub_screen.dart';
import '../../features/registry/presentation/registry_cin_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.splashPath,
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingPath,
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.createAccountPath,
        name: AppRoutes.createAccount,
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpPath,
        name: AppRoutes.otp,
        builder: (context, state) =>
            OtpScreen(email: state.uri.queryParameters['email'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.editProfilePath,
        name: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.sellPath,
        name: AppRoutes.sell,
        builder: (context, state) {
          final extra = state.extra;
          return SellCompanyScreen(
            prefill: extra is ListingPrefill ? extra : null,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.listingPath,
        name: AppRoutes.listing,
        builder: (context, state) =>
            ListingDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.companiesPath,
        name: AppRoutes.companies,
        builder: (context, state) => CompanyListingsScreen(
          typeId: state.uri.queryParameters['type'] ?? '',
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            BuyerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.homePath,
                name: AppRoutes.home,
                builder: (context, state) => const BuyerDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.sellTabPath,
                name: AppRoutes.sellTab,
                builder: (context, state) => const SellHubScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.searchPath,
                name: AppRoutes.search,
                builder: (context, state) => const RegistryCinScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.buyPath,
                name: AppRoutes.buy,
                builder: (context, state) => BuyScreen(
                  initialQuery: state.uri.queryParameters['q'] ?? '',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profilePath,
                name: AppRoutes.profile,
                builder: (context, state) => const BuyerProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

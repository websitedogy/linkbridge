import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/token_store.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/marketplace_api.dart';
import '../../auth/application/account_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _gifAsset = 'assets/brand/linkbridge.gif';

  ui.Image? _frame;
  AppAccount? _account;
  var _sessionReady = false;
  var _gifDone = false;
  var _left = false;
  Timer? _fallback;

  @override
  void initState() {
    super.initState();
    // Decoding can stall on some devices; never keep the user on splash.
    _fallback = Timer(const Duration(seconds: 6), _finishGif);
    _loadSession();
    _playGif();
  }

  Future<void> _loadSession() async {
    AppAccount? account;
    try {
      final token = await TokenStore.instance.read().timeout(
        const Duration(milliseconds: 2200),
      );
      if (token != null && token.isNotEmpty) {
        final user = await MarketplaceApi().me().timeout(
          const Duration(seconds: 8),
        );
        if (user != null) {
          account = AppAccount.fromApi(user);
          await AccountStore.instance.save(account);
        }
      }
    } on ApiException catch (error) {
      if (error.status == 401) {
        await TokenStore.instance.clear();
        await AccountStore.instance.clear();
      } else {
        account = await AccountStore.instance.read();
      }
    } catch (_) {
      account = null;
    }
    if (!mounted) {
      return;
    }
    _account = account;
    _sessionReady = true;
    _leave();
  }

  Future<void> _playGif() async {
    ui.Codec? codec;
    try {
      final data = await rootBundle.load(_gifAsset);
      codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      for (var i = 0; i < codec.frameCount; i++) {
        if (!mounted) {
          return;
        }
        final frame = await codec.getNextFrame();
        final previous = _frame;
        setState(() => _frame = frame.image);
        previous?.dispose();
        final ms = frame.duration.inMilliseconds;
        await Future<void>.delayed(Duration(milliseconds: ms == 0 ? 100 : ms));
      }
    } catch (_) {
      // A missing or unreadable file must not trap the user on splash.
    } finally {
      codec?.dispose();
    }
    _finishGif();
  }

  void _finishGif() {
    _fallback?.cancel();
    if (!mounted) {
      return;
    }
    _gifDone = true;
    _leave();
  }

  void _leave() {
    if (_left || !_sessionReady || !_gifDone || !mounted) {
      return;
    }
    _left = true;
    final account = _account;
    if (account != null) {
      ref.read(accountControllerProvider.notifier).restore(account);
      context.goNamed(AppRoutes.home);
      return;
    }
    context.goNamed(AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _fallback?.cancel();
    _frame?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = _frame;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFD5D8DC),
        body: Semantics(
          label: 'LinksBridge',
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (frame != null)
                FittedBox(
                  fit: BoxFit.cover,
                  child: RawImage(
                    image: frame,
                    width: frame.width.toDouble(),
                    height: frame.height.toDouble(),
                  ),
                ),
              const _BrandWordmark(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark();

  @override
  Widget build(BuildContext context) {
    final linksStyle = AppTypography.title(color: Colors.white).copyWith(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
      height: 1,
    );
    final bridgeStyle = linksStyle.copyWith(color: AppColors.gold);

    return Align(
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x00070B12), Color(0x990B1F16), Color(0xF0122A20)],
            stops: [0, 0.4, 1],
          ),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Links', style: linksStyle),
                        TextSpan(text: 'Bridge', style: bridgeStyle),
                      ],
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 64,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0x00D4A537),
                        AppColors.gold,
                        Color(0xFFF6E3A8),
                        AppColors.gold,
                        Color(0x00D4A537),
                      ],
                    ),
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

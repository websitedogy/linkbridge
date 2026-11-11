import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/token_store.dart';
import '../data/marketplace_api.dart';

final apiProvider = Provider<MarketplaceApi>((ref) => MarketplaceApi());

final sessionProvider =
    AsyncNotifierProvider<SessionController, Map<String, dynamic>?>(
      SessionController.new,
    );

class SessionController extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() async {
    final token = await TokenStore.instance.read();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      return await ref.read(apiProvider).me();
    } catch (_) {
      return null;
    }
  }

  Future<void> requestOtp({required String email}) {
    return ref.read(apiProvider).requestOtp(email: email);
  }

  Future<String?> verifyOtp({required String email, required String otp}) {
    return _authenticate(
      () => ref.read(apiProvider).verifyOtp(email: email, otp: otp),
    );
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String mobile,
    required String role,
  }) {
    return ref
        .read(apiProvider)
        .register(name: name, email: email, mobile: mobile, role: role)
        .then((_) {});
  }

  Future<void> signOut() async {
    await ref.read(apiProvider).logout();
    state = const AsyncData(null);
  }

  Future<String?> _authenticate(
    Future<Map<String, dynamic>?> Function() action,
  ) async {
    state = const AsyncLoading();
    try {
      final user = await action();
      final profile = await ref.read(apiProvider).me();
      state = AsyncData(profile ?? user);
      final role = (profile ?? user)?['role'];
      return role is String ? role : null;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }
}

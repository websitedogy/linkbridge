import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:linksbridge/core/config/app_env.dart';
import 'package:linksbridge/core/network/api_client.dart';

final _ready = Provider<String>((ref) => 'ok');

void main() {
  test('development API client uses the local API', () {
    expect(AppEnv.name, 'development');
    expect(AppEnv.apiBaseUrl, 'http://localhost:8000/api/v1');

    final client = createApiClient();
    expect(client, isA<Dio>());
    expect(client.options.baseUrl, AppEnv.apiBaseUrl);
  });

  test('router, riverpod, and secure storage packages construct', () {
    final router = GoRouter(routes: const []);
    addTearDown(router.dispose);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(_ready), 'ok');

    const storage = FlutterSecureStorage();
    expect(storage, isNotNull);
  });
}

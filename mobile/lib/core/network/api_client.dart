import 'package:dio/dio.dart';

import '../auth/token_store.dart';
import '../config/app_env.dart';

Dio createApiClient() {
  final client = Dio(
    BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      headers: const {'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  client.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (!_isPublicAuth(options.path)) {
          try {
            final token = await TokenStore.instance.read().timeout(
              const Duration(milliseconds: 800),
            );
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {}
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final fallback = AppEnv.apiFallbackUrl;
        if (fallback == null ||
            error.requestOptions.extra['lb_retried'] == true ||
            !_shouldRetry(error)) {
          handler.next(error);
          return;
        }
        final request = error.requestOptions;
        request
          ..baseUrl = fallback
          ..extra['lb_retried'] = true;
        try {
          handler.resolve(await client.fetch(request));
        } on DioException catch (retryError) {
          handler.next(retryError);
        }
      },
    ),
  );

  return client;
}

bool _shouldRetry(DioException error) {
  return error.response == null &&
      (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.unknown);
}

bool _isPublicAuth(String path) {
  return path.contains('/auth/login') ||
      path.contains('/auth/register') ||
      path.contains('/auth/verify-otp') ||
      path.contains('/auth/resend-otp');
}

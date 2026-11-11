import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException(this.status, this.message);

  final int status;
  final String message;

  factory ApiException.fromDio(DioException error) {
    final status = error.response?.statusCode ?? 0;
    final data = error.response?.data;
    final fieldMessage = _firstFieldError(data);
    final serverMessage =
        fieldMessage ??
        (data is Map && data['message'] is String
            ? data['message'] as String
            : null);

    return ApiException(status, switch (status) {
      401 => serverMessage ?? 'Your session has expired. Please sign in again.',
      403 => 'You do not have permission to do that.',
      404 => 'We could not find what you requested.',
      422 => serverMessage ?? 'Please check the form and try again.',
      429 => 'Too many attempts. Please wait a moment and try again.',
      0 => 'Network error. Check your connection and try again.',
      _ =>
        status >= 500
            ? 'Something went wrong on the server. Please try again.'
            : serverMessage ?? 'Request failed.',
    });
  }

  @override
  String toString() => message;

  static String? _firstFieldError(dynamic data) {
    if (data is! Map || data['errors'] is! Map) return null;
    for (final value in (data['errors'] as Map).values) {
      if (value is List && value.isNotEmpty) return value.first.toString();
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}

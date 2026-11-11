import 'package:dio/dio.dart';

import '../core/auth/token_store.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';

class MarketplaceApi {
  MarketplaceApi({Dio? dio}) : _dio = dio ?? createApiClient();

  final Dio _dio;

  Future<void> requestOtp({required String email}) async {
    await _send('/auth/login', data: {'email': email});
  }

  Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String mobile,
    required String role,
  }) async {
    await _send(
      '/auth/register',
      data: {'name': name, 'email': email, 'mobile': mobile, 'role': role},
    );
    return {'email': email};
  }

  Future<void> resendOtp({required String email}) async {
    await _send('/auth/resend-otp', data: {'email': email});
  }

  Future<Map<String, dynamic>?> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final payload = await _send(
      '/auth/verify-otp',
      data: {'email': email, 'otp': otp},
    );
    final token = payload['token'];
    if (token is String) {
      await TokenStore.instance.save(token);
    }
    return payload['user'] as Map<String, dynamic>?;
  }

  Future<void> logout() async {
    try {
      await _send('/auth/logout');
    } finally {
      await TokenStore.instance.clear();
    }
  }

  Future<Map<String, dynamic>?> updateProfile({
    required String name,
    String? email,
    String? mobile,
    String? currentPassword,
    String? password,
  }) async {
    final data = await _put(
      '/auth/profile',
      data: {
        'name': name,
        'email': email,
        'mobile': mobile,
        if (currentPassword != null && currentPassword.isNotEmpty)
          'current_password': currentPassword,
        if (password != null && password.isNotEmpty) ...{
          'password': password,
          'password_confirmation': password,
        },
      },
    );
    return data;
  }

  Future<Map<String, dynamic>?> me() async {
    return _get('/auth/me');
  }

  Future<List<Map<String, dynamic>>> locations(String type) async {
    return _list(await _get('/locations?type=$type'));
  }

  Future<Map<String, dynamic>> ask(String message) {
    return _send('/assistant', data: {'message': message});
  }

  Future<List<Map<String, dynamic>>> listings({String query = ''}) async {
    final data = await _get('/listings$query');
    return _list(data);
  }

  Future<Map<String, dynamic>> listing(String slug) async {
    return _get('/listings/$slug');
  }

  Future<List<Map<String, dynamic>>> registrySubmissions() async =>
      _list(await _get('/registry-submissions'));

  Future<Map<String, dynamic>> createRegistrySubmission({
    required String companyType,
    required String companyName,
    String? cin,
    required String directorContact,
    required String directorEmail,
    required String location,
    double? latitude,
    double? longitude,
  }) {
    return _send(
      '/registry-submissions',
      data: {
        'company_type': companyType,
        'company_name': companyName,
        'cin': cin,
        'director_contact': directorContact,
        'director_email': directorEmail,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  Future<List<Map<String, dynamic>>> favorites() async =>
      _list(await _get('/buyer/favorites'));

  Future<void> favorite(String id) => _send('/buyer/favorites/$id');

  Future<List<Map<String, dynamic>>> interests() async =>
      _list(await _get('/buyer/interests'));

  Future<void> expressInterest(String id, String message) {
    return _send('/buyer/listings/$id/interest', data: {'message': message});
  }

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final response = await _dio.get(path);
      return _body(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> _put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return _body(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> _send(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return _body(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Map<String, dynamic> _body(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      if (raw['success'] == true) {
        final data = raw['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
        return {'items': data};
      }
      throw ApiException(400, raw['message']?.toString() ?? 'Request failed.');
    }
    throw ApiException(500, 'The server returned an unexpected response.');
  }

  List<Map<String, dynamic>> _list(Map<String, dynamic> body) {
    final items = body['items'];
    if (items is List) {
      return items.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore._();

  static final instance = TokenStore._();
  static const _key = 'linksbridge_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _memory;

  Future<String?> read() async {
    if (_memory != null) {
      return _memory;
    }

    try {
      _memory = await _storage.read(key: _key);
    } catch (_) {
      _memory = null;
    }

    return _memory;
  }

  Future<void> save(String token) async {
    _memory = token;
    try {
      await _storage.write(key: _key, value: token);
    } catch (_) {}
  }

  Future<void> clear() async {
    _memory = null;
    try {
      await _storage.delete(key: _key);
    } catch (_) {}
  }
}

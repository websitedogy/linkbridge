import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../data/marketplace_api.dart';

import '../../../core/models/user_role.dart';

class AppAccount {
  const AppAccount({
    required this.name,
    required this.contact,
    this.email = '',
    this.mobile = '',
    this.role,
    this.password = '',
  });

  final String name;
  final String contact;
  final String email;
  final String mobile;
  final UserRole? role;
  final String password;

  factory AppAccount.fromApi(Map<String, dynamic> user) {
    final email = user['email']?.toString() ?? '';
    final mobile = user['mobile']?.toString() ?? '';
    final roleName = user['role']?.toString().toLowerCase();
    return AppAccount(
      name: user['name']?.toString() ?? '',
      email: email,
      mobile: mobile,
      contact: email.isNotEmpty ? email : mobile,
      role: UserRole.values.where((role) => role.name == roleName).firstOrNull,
    );
  }

  AppAccount copyWith({
    String? name,
    String? contact,
    String? email,
    String? mobile,
    UserRole? role,
    String? password,
  }) {
    return AppAccount(
      name: name ?? this.name,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      role: role ?? this.role,
      password: password ?? this.password,
    );
  }
}

class AccountStore {
  AccountStore._();

  static final instance = AccountStore._();
  static const _key = 'linksbridge_account';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _memory;

  Future<AppAccount?> read() async {
    try {
      _memory ??= await _storage.read(key: _key);
    } catch (_) {
      _memory = null;
    }
    return _decode(_memory);
  }

  Future<void> save(AppAccount account) async {
    final raw = jsonEncode({
      'name': account.name,
      'contact': account.contact,
      'email': account.email,
      'mobile': account.mobile,
      'role': account.role?.name,
    });
    _memory = raw;
    try {
      await _storage.write(key: _key, value: raw);
    } catch (_) {}
  }

  Future<void> clear() async {
    _memory = null;
    try {
      await _storage.delete(key: _key);
    } catch (_) {}
  }

  AppAccount? _decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final roleName = map['role']?.toString();
      return AppAccount(
        name: map['name']?.toString() ?? '',
        contact: map['contact']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        mobile: map['mobile']?.toString() ?? '',
        role: UserRole.values
            .where((role) => role.name == roleName)
            .firstOrNull,
        password: map['password']?.toString() ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}

class AccountController extends Notifier<AppAccount?> {
  @override
  AppAccount? build() {
    _hydrate();
    return null;
  }

  Future<void> _hydrate() async {
    final saved = await AccountStore.instance.read();
    if (!ref.mounted || saved == null || state != null) return;
    state = saved;
  }

  Future<void> signIn(AppAccount account) async {
    state = account;
    await AccountStore.instance.save(account);
  }

  void restore(AppAccount account) => state = account;

  Future<void> signOut() async {
    try {
      await MarketplaceApi().logout();
    } catch (_) {}
    state = null;
    await AccountStore.instance.clear();
  }
}

final accountControllerProvider =
    NotifierProvider<AccountController, AppAccount?>(AccountController.new);

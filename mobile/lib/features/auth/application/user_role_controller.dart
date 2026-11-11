import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/user_role.dart';

class UserRoleController extends Notifier<UserRole?> {
  @override
  UserRole? build() => null;

  void select(UserRole role) => state = role;
}

final userRoleProvider = NotifierProvider<UserRoleController, UserRole?>(
  UserRoleController.new,
);

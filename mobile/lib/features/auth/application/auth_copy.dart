import '../../../core/network/api_exception.dart';

abstract final class AuthCopy {
  static const noAccount = 'No account found. Please sign up.';
  static const accountExists = 'This account already exists. Please login.';
  static const wrongPassword = 'Incorrect password.';

  static String loginError(ApiException error) {
    if (_keepServerMessage(error)) {
      return error.message;
    }
    final message = error.message.toLowerCase();
    if (message.contains('incorrect password')) {
      return wrongPassword;
    }
    if (message.contains('no account') ||
        message.contains('do not match') ||
        message.contains('invalid credentials') ||
        message.contains('could not find') ||
        message.contains('not found')) {
      return noAccount;
    }
    return error.message;
  }

  static String registerError(ApiException error) {
    if (_keepServerMessage(error)) {
      return error.message;
    }
    final message = error.message.toLowerCase();
    if (message.contains('already been taken') ||
        message.contains('already exists') ||
        message.contains('has already been')) {
      return accountExists;
    }
    return error.message;
  }

  static bool _keepServerMessage(ApiException error) {
    return error.status == 0 || error.status >= 500;
  }
}

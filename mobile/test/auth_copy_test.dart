import 'package:flutter_test/flutter_test.dart';
import 'package:linksbridge/core/network/api_exception.dart';
import 'package:linksbridge/features/auth/application/auth_copy.dart';

void main() {
  test('login shows sign up when the account is missing', () {
    expect(
      AuthCopy.loginError(
        ApiException(422, 'No account found. Please sign up.'),
      ),
      AuthCopy.noAccount,
    );
    expect(
      AuthCopy.loginError(ApiException(401, 'Invalid credentials provided.')),
      AuthCopy.noAccount,
    );
  });

  test('login keeps the password error when the account exists', () {
    expect(
      AuthCopy.loginError(ApiException(422, 'Incorrect password.')),
      AuthCopy.wrongPassword,
    );
  });

  test('sign up asks to login when the account already exists', () {
    expect(
      AuthCopy.registerError(
        ApiException(422, 'The email has already been taken.'),
      ),
      AuthCopy.accountExists,
    );
    expect(
      AuthCopy.registerError(
        ApiException(422, 'This account already exists. Please login.'),
      ),
      AuthCopy.accountExists,
    );
  });

  test('network failures keep the original message', () {
    const network = 'Network error. Check your connection and try again.';
    expect(AuthCopy.loginError(ApiException(0, network)), network);
    expect(AuthCopy.registerError(ApiException(0, network)), network);
  });
}

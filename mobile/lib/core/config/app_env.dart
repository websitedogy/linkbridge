/// Runtime configuration. Pass values with `--dart-define`.
///
/// Staging and production hosts below are placeholders. Replace them before
/// those environments exist. Do not put secrets in this file.
class AppEnv {
  static const name = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    switch (name) {
      case 'staging':
        return 'https://staging-api.example.com/api/v1';
      case 'production':
        return 'https://api.example.com/api/v1';
      default:
        // USB: adb reverse tcp:8010 tcp:8010
        return 'http://127.0.0.1:8010/api/v1';
    }
  }

  static String? get apiFallbackUrl {
    if (_apiBaseUrlOverride.isNotEmpty || name != 'development') {
      return null;
    }
    return 'http://192.168.0.100:8010/api/v1';
  }
}

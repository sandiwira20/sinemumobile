class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'SINEMU_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const String googleServerClientId = String.fromEnvironment(
    'SINEMU_GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  static const Duration timeout = Duration(seconds: 20);
}

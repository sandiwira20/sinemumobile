import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../user_data.dart';

class AuthService {
  AuthService({ApiClient? apiClient, TokenStorage? tokenStorage})
    : _apiClient = apiClient ?? ApiClient(tokenStorage: tokenStorage),
      _tokenStorage = tokenStorage ?? const TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/login',
      requiresAuth: false,
      body: {'login': login, 'password': password},
    );

    return _persistLoginResponse(response);
  }

  Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
  }) async {
    final response = await _apiClient.post(
      '/login/google',
      requiresAuth: false,
      body: {'id_token': idToken},
    );

    return _persistLoginResponse(response);
  }

  Future<Map<String, dynamic>> _persistLoginResponse(dynamic response) async {
    final data = _asMap(response);
    final token = _extractToken(data);
    if (token == null || token.isEmpty) {
      throw const ApiException('Token login tidak ditemukan dari server.');
    }

    await _tokenStorage.saveToken(token);

    final user = _extractUser(data);
    if (user != null) {
      UserData.updateFromJson(user);
    }

    return data;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.get('/profile');
    final data = _asMap(response);
    final user = _extractUser(data) ?? data;

    UserData.updateFromJson(user);
    return user;
  }

  Future<void> logout() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      await _tokenStorage.clearToken();
      return;
    }

    try {
      await _apiClient.post('/logout');
    } finally {
      await _tokenStorage.clearToken();
    }
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    throw const ApiException('Format response server tidak sesuai.');
  }

  String? _extractToken(Map<String, dynamic> data) {
    for (final key in ['token', 'access_token', 'plainTextToken']) {
      final value = data[key];
      if (value is String) {
        return value;
      }
    }

    final nestedData = data['data'];
    if (nestedData is Map<String, dynamic>) {
      for (final key in ['token', 'access_token', 'plainTextToken']) {
        final value = nestedData[key];
        if (value is String) {
          return value;
        }
      }
    }

    return null;
  }

  Map<String, dynamic>? _extractUser(Map<String, dynamic> data) {
    final user = data['user'];
    if (user is Map<String, dynamic>) {
      return user;
    }

    final nestedData = data['data'];
    if (nestedData is Map<String, dynamic>) {
      final nestedUser = nestedData['user'];
      if (nestedUser is Map<String, dynamic>) {
        return nestedUser;
      }

      if (nestedData.containsKey('email') || nestedData.containsKey('name')) {
        return nestedData;
      }
    }

    return null;
  }
}

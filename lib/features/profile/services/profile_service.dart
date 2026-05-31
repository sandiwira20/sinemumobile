import '../../../core/network/api_client.dart';
import '../../../user_data.dart';
import '../models/profile_model.dart';

class ProfileService {
  ProfileService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ProfileModel> getProfile() async {
    final response = await _apiClient.get('/profile');
    final profile = ProfileModel.fromJson(_extractProfileMap(response));
    UserData.updateFromProfile(profile);
    return profile;
  }

  Future<void> updateProfile(ProfileModel profile) async {
    await _apiClient.put('/profile', body: profile.toUpdateJson());
    UserData.updateFromProfile(profile);
  }

  Map<String, dynamic> _extractProfileMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      for (final key in ['data', 'user', 'profile']) {
        final value = response[key];
        if (value is Map) {
          final map = Map<String, dynamic>.from(value);
          final nestedUser = map['user'];
          if (nestedUser is Map) {
            return Map<String, dynamic>.from(nestedUser);
          }

          return map;
        }
      }

      return response;
    }

    throw const ApiException('Format profile dari server tidak sesuai.');
  }
}

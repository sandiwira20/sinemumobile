import 'features/profile/models/profile_model.dart';

class UserData {
  static String nama = "";
  static String email = "";
  static String fotoUrl = "";
  static String username = "";
  static String phone = "";
  static String alamat = "";

  static void updateFromJson(Map<String, dynamic> user) {
    nama = _readString(user, ['name', 'nama', 'nama_lengkap']) ?? nama;
    email = _readString(user, ['email', 'login']) ?? email;
    username = _readString(user, ['username', 'user_name']) ?? username;
    phone =
        _readString(user, [
          'phone',
          'no_hp',
          'nomor_hp',
          'telepon',
          'nomor_telepon',
        ]) ??
        phone;
    alamat = _readString(user, ['alamat', 'address', 'lokasi']) ?? alamat;
    fotoUrl = _readString(user, ['foto_url', 'photo_url', 'avatar']) ?? fotoUrl;
  }

  static void updateFromProfile(ProfileModel profile) {
    nama = profile.name;
    email = profile.email;
    username = profile.username;
    phone = profile.phone;
    alamat = profile.alamat;
    fotoUrl = profile.photoUrl;
  }

  static void reset() {
    nama = "";
    email = "";
    fotoUrl = "";
    username = "";
    phone = "";
    alamat = "";
  }

  static String? _readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return null;
  }
}

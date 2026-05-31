class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.phone,
    required this.alamat,
    required this.photoUrl,
  });

  final String id;
  final String name;
  final String email;
  final String username;
  final String phone;
  final String alamat;
  final String photoUrl;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: _readString(json, ['id', 'user_id']) ?? '',
      name:
          _readString(json, ['name', 'nama', 'nama_lengkap', 'full_name']) ??
          'User',
      email: _readString(json, ['email', 'login']) ?? '-',
      username: _readString(json, ['username', 'user_name']) ?? '',
      phone:
          _readString(json, [
            'phone',
            'no_hp',
            'nomor_hp',
            'telepon',
            'nomor_telepon',
          ]) ??
          '',
      alamat: _readString(json, ['alamat', 'address', 'lokasi']) ?? '',
      photoUrl: _readString(json, ['foto_url', 'photo_url', 'avatar']) ?? '',
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'alamat': alamat,
    };
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

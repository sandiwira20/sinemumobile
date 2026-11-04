class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'SINEMU_API_BASE_URL',
    defaultValue: 'https://sinemu.my.id/api',
  );

  /// Root URL tanpa akhiran '/api'
  static String get rootUrl {
    final base = baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (base.endsWith('/api')) {
      return base.substring(0, base.length - 4);
    }
    return base;
  }

  /// Normalisasi path relatif gambar/media menjadi URL lengkap
  static String normalizeImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim().replaceAll(r'\', '/');

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    var path = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;

    if (path.startsWith('public/')) {
      path = path.substring(7);
    }
    if (path.startsWith('storage/')) {
      path = path.substring(8);
    }

    if (path.startsWith('barang-temuan/') ||
        path.startsWith('barang-hilang/') ||
        path.startsWith('verifikasi-klaim/')) {
      return '$rootUrl/media/$path';
    }

    return '$rootUrl/storage/$path';
  }

  static const String googleServerClientId = String.fromEnvironment(
    'SINEMU_GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  static const Duration timeout = Duration(seconds: 60);
}

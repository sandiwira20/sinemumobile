class LaporanModel {
  const LaporanModel({
    required this.id,
    required this.type,
    required this.namaBarang,
    required this.kategoriId,
    required this.kategori,
    required this.wilayahId,
    required this.wilayah,
    required this.lokasi,
    required this.deskripsi,
    required this.status,
    required this.tanggal,
    required this.imageUrl,
    this.warnaDominan,
    this.merek,
    this.nomorSeri,
    this.perkiraanJam,
    this.claimable = false,
    this.claimBlockReason,
    this.isOwner = false,
    this.statusBarang = '',
  });

  final String id;
  final String type;
  final String namaBarang;
  final String kategoriId;
  final String kategori;
  final String wilayahId;
  final String wilayah;
  final String lokasi;
  final String deskripsi;
  final String status;
  final String tanggal;
  final String imageUrl;
  final String? warnaDominan;
  final String? merek;
  final String? nomorSeri;
  final String? perkiraanJam;
  final bool claimable;
  final String? claimBlockReason;
  final bool isOwner;
  final String statusBarang;

  // ─── BASE URL untuk normalisasi gambar ───
  static const String _apiBase = 'https://sinemu.kelompok4.org';

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    final type = _normalizeType(
      _readString(json, [
        'type',
        'jenis',
        'jenis_laporan',
        'tipe',
        'tipe_laporan',
      ]),
    );

    final rawImageUrl =
        _readString(json, [
          'image_url',
          'foto_url',
          'gambar_url',
          'photo_url',
          'foto',
          'gambar',
          'image',
        ]) ??
        '';

    return LaporanModel(
      id: _readString(json, ['id', 'laporan_id']) ?? '',
      type: type,
      namaBarang:
          _readString(json, ['nama_barang', 'nama', 'namaBarang', 'title']) ??
          'Tanpa nama barang',
      kategoriId:
          _readString(json, ['kategori_id', 'id_kategori']) ??
          _readNestedValue(json, 'kategori', ['id', 'kategori_id', 'value']) ??
          '',
      kategori:
          _readNestedString(json, 'kategori') ??
          _readString(json, ['nama_kategori', 'kategori_nama']) ??
          '-',
      wilayahId:
          _readString(json, ['wilayah_id', 'id_wilayah']) ??
          _readNestedValue(json, 'wilayah', ['id', 'wilayah_id', 'value']) ??
          '',
      wilayah:
          _readNestedString(json, 'wilayah') ??
          _readString(json, ['nama_wilayah', 'wilayah_nama', 'kecamatan']) ??
          '-',
      lokasi: _readString(json, ['lokasi', 'alamat', 'location']) ?? '-',
      deskripsi:
          _readString(json, ['deskripsi', 'description', 'keterangan']) ?? '-',
      status: _readString(json, ['status', 'state']) ?? '-',
      tanggal:
          _readString(json, [
            'tanggal',
            'tanggal_hilang',
            'tanggal_ditemukan',
            'created_at',
          ]) ??
          '-',
      imageUrl: _normalizeImageUrl(rawImageUrl), // ← PERBAIKAN DI SINI
      warnaDominan: _readString(json, ['warna_dominan', 'warna']),
      merek: _readString(json, ['merek', 'brand', 'merk']),
      nomorSeri: _readString(json, [
        'nomor_seri',
        'serial_number',
        'kode_unik',
      ]),
      perkiraanJam: _readString(json, ['perkiraan_jam', 'jam_hilang', 'jam']),
      claimable: _readBool(json, ['claimable', 'can_claim']) ?? false,
      claimBlockReason: _readString(json, [
        'claim_block_reason',
        'claimBlockReason',
        'claim_reason',
      ]),
      isOwner: _readBool(json, ['is_owner', 'isOwner']) ?? false,
      statusBarang: _readString(json, ['status_barang', 'statusBarang']) ?? '',
    );
  }

  int? get numericId => int.tryParse(id);

  bool get isHilang => type == 'hilang';
  bool get isTemuan => type == 'temuan';

  LaporanModel copyWith({
    bool? claimable,
    String? claimBlockReason,
    bool? isOwner,
    String? statusBarang,
    String? warnaDominan,
    String? merek,
    String? nomorSeri,
    String? perkiraanJam,
  }) {
    return LaporanModel(
      id: id,
      type: type,
      namaBarang: namaBarang,
      kategoriId: kategoriId,
      kategori: kategori,
      wilayahId: wilayahId,
      wilayah: wilayah,
      lokasi: lokasi,
      deskripsi: deskripsi,
      status: status,
      tanggal: tanggal,
      imageUrl: imageUrl,
      warnaDominan: warnaDominan ?? this.warnaDominan,
      merek: merek ?? this.merek,
      nomorSeri: nomorSeri ?? this.nomorSeri,
      perkiraanJam: perkiraanJam ?? this.perkiraanJam,
      claimable: claimable ?? this.claimable,
      claimBlockReason: claimBlockReason ?? this.claimBlockReason,
      isOwner: isOwner ?? this.isOwner,
      statusBarang: statusBarang ?? this.statusBarang,
    );
  }

  String get jenisLabel {
    if (isHilang) return 'Hilang';
    if (isTemuan) return 'Temuan';
    return type.isEmpty ? '-' : _capitalize(type);
  }

  String get jenisBadge => jenisLabel.toUpperCase();

  String get tanggalDisplay {
    if (tanggal.length >= 10) return tanggal.substring(0, 10);
    return tanggal;
  }

  // ─── HELPER: Normalisasi URL gambar ───────────────────────────
  static String _normalizeImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '$_apiBase$url';
    return '$_apiBase/$url';
  }

  static String _normalizeType(String? value) {
    final normalized = value?.toLowerCase().trim() ?? '';
    if (normalized.contains('hilang')) return 'hilang';
    if (normalized.contains('temuan') || normalized.contains('ditemukan')) {
      return 'temuan';
    }
    return normalized;
  }

  static String? _readNestedString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String && value.trim().isNotEmpty) return value;
    if (value is Map<String, dynamic>) {
      return _readString(value, ['nama', 'name', 'label', 'nama_$key']);
    }
    return null;
  }

  static String? _readNestedValue(
    Map<String, dynamic> data,
    String key,
    List<String> nestedKeys,
  ) {
    final value = data[key];
    if (value is Map<String, dynamic>) {
      return _readString(value, nestedKeys);
    }
    return null;
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

  static bool? _readBool(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.toLowerCase().trim();
        if (['true', '1', 'yes', 'ya'].contains(normalized)) return true;
        if (['false', '0', 'no', 'tidak'].contains(normalized)) return false;
      }
    }
    return null;
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class KlaimModel {
  const KlaimModel({
    required this.id,
    required this.barangId,
    required this.namaBarang,
    required this.status,
    required this.alasan,
    required this.kontak,
    required this.tanggal,
    required this.statusBarang,
  });

  final String id;
  final String barangId;
  final String namaBarang;
  final String status;
  final String alasan;
  final String kontak;
  final String tanggal;
  final String statusBarang;

  factory KlaimModel.fromJson(Map<String, dynamic> json) {
    return KlaimModel(
      id: _readString(json, ['id', 'klaim_id']) ?? '',
      barangId:
          _readString(json, ['barang_id', 'barang_temuan_id', 'laporan_id']) ??
          _readNestedValue(json, 'barang', ['id', 'barang_id']) ??
          _readNestedValue(json, 'barang_temuan', ['id', 'barang_id']) ??
          '',
      namaBarang:
          _readString(json, ['nama_barang', 'nama', 'title']) ??
          _readNestedValue(json, 'barang', ['nama_barang', 'nama', 'title']) ??
          _readNestedValue(json, 'barang_temuan', [
            'nama_barang',
            'nama',
            'title',
          ]) ??
          'Tanpa nama barang',
      status: _readString(json, ['status', 'status_klaim', 'state']) ?? '-',
      alasan:
          _readString(json, ['alasan', 'alasan_klaim', 'keterangan']) ?? '-',
      kontak:
          _readString(json, ['kontak', 'no_hp', 'nomor_hp', 'phone']) ?? '-',
      tanggal:
          _readString(json, ['tanggal', 'tanggal_pengajuan', 'created_at']) ??
          '-',
      statusBarang:
          _readString(json, ['status_barang']) ??
          _readNestedValue(json, 'barang', ['status', 'status_barang']) ??
          _readNestedValue(json, 'barang_temuan', [
            'status',
            'status_barang',
          ]) ??
          '',
    );
  }

  int? get numericId => int.tryParse(id);

  String get statusLabel => _label(status);

  String get statusBarangLabel {
    if (statusBarang.trim().isEmpty || statusBarang == '-') {
      return '-';
    }

    return _label(statusBarang);
  }

  String get tanggalDisplay {
    if (tanggal.length >= 10) {
      return tanggal.substring(0, 10);
    }

    return tanggal;
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

  static String _label(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return '-';
    }

    return normalized
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}

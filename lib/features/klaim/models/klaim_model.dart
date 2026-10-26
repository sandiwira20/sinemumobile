class KlaimModel {
  const KlaimModel({
    required this.id,
    required this.nomorKlaim,
    required this.barangId,
    required this.namaBarang,
    required this.status,
    required this.alasan,
    required this.kontak,
    required this.tanggal,
    required this.statusBarang,
    required this.wilayah,
    this.fotoBarang = '',
    this.kodePengambilan = '',
    this.namaPosko = '',
    this.alamatPosko = '',
    this.wilayahPosko = '',
    this.jamLayanan = '',
    this.penanggungJawab = '',
    this.catatanPosko = '',

    // Data pemilik/pengaju klaim
    this.namaPengambil = '',
    this.emailPengambil = '',

    // Rincian barang temuan
    this.kategoriBarang = '',
    this.lokasiDitemukan = '',
    this.tanggalTemuan = '',
    this.deskripsiBarang = '',
    this.warnaDominan = '',
    this.merek = '',
    this.nomorSeri = '',

    // Status dan kontak tambahan
    this.statusText = '',
    this.statusDescription = '',
    this.siapDiambil = false,
    this.selesai = false,
    this.kontakPosko = '',
    this.waUrl = '',
    this.telHref = '',
    this.emailAdmin = '',
  });

  // Data klaim
  final String id;
  final String nomorKlaim;
  final String barangId;
  final String namaBarang;
  final String status;
  final String alasan;
  final String kontak;
  final String tanggal;
  final String statusBarang;
  final String wilayah;

  // Foto dan panduan pengambilan
  final String fotoBarang;
  final String kodePengambilan;
  final String namaPosko;
  final String alamatPosko;
  final String wilayahPosko;
  final String jamLayanan;
  final String penanggungJawab;
  final String catatanPosko;

  // Data pemilik/pengaju klaim
  final String namaPengambil;
  final String emailPengambil;

  // Rincian barang temuan
  final String kategoriBarang;
  final String lokasiDitemukan;
  final String tanggalTemuan;
  final String deskripsiBarang;
  final String warnaDominan;
  final String merek;
  final String nomorSeri;

  // Status dan kontak tambahan
  final String statusText;
  final String statusDescription;
  final bool siapDiambil;
  final bool selesai;
  final String kontakPosko;
  final String waUrl;
  final String telHref;
  final String emailAdmin;

  factory KlaimModel.fromJson(Map<String, dynamic> json) {
    final barang = _nestedMap(json, 'barang');
    final barangTemuan = _nestedMap(json, 'barang_temuan');
    final kategori = _nestedMap(barang, 'kategori');
    final kategoriTemuan = _nestedMap(barangTemuan, 'kategori');

    return KlaimModel(
      // Data klaim
      id: _readString(json, ['id', 'klaim_id']) ?? '',
      nomorKlaim:
          _readString(json, ['nomor_klaim', 'klaim_number']) ??
          _readString(json, ['id']) ??
          '',
      barangId:
          _readString(json, ['barang_id', 'barang_temuan_id', 'laporan_id']) ??
          _readString(barang, ['id', 'barang_id']) ??
          _readString(barangTemuan, ['id', 'barang_id']) ??
          '',
      namaBarang:
          _readString(json, ['nama_barang', 'nama', 'title']) ??
          _readString(barang, ['nama_barang', 'nama', 'title']) ??
          _readString(barangTemuan, ['nama_barang', 'nama', 'title']) ??
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
          _readString(json, ['status_barang', 'status_text']) ??
          _readString(barang, ['status', 'status_barang']) ??
          _readString(barangTemuan, ['status', 'status_barang']) ??
          '',
      wilayah:
          _readString(json, ['wilayah', 'area']) ??
          _readString(barang, ['wilayah', 'area']) ??
          _readString(barangTemuan, ['wilayah', 'area']) ??
          '',

      // Foto barang
      fotoBarang:
          _readString(json, ['foto_barang', 'item_image_url', 'image_url']) ??
          _readString(barang, ['foto_barang', 'image_url', 'foto']) ??
          _readString(barangTemuan, ['foto_barang', 'image_url', 'foto']) ??
          '',

      // Panduan pengambilan
      kodePengambilan:
          _readString(json, ['kode_pengambilan', 'claim_code']) ?? '',
      namaPosko: _readString(json, ['nama_posko', 'posko_name']) ?? '',
      alamatPosko: _readString(json, ['alamat_posko', 'posko_address']) ?? '',
      wilayahPosko: _readString(json, ['wilayah_posko', 'posko_region']) ?? '',
      jamLayanan: _readString(json, ['jam_layanan', 'service_hours']) ?? '',
      penanggungJawab:
          _readString(json, ['penanggung_jawab', 'person_in_charge']) ?? '',
      catatanPosko: _readString(json, ['catatan_posko', 'pickup_notes']) ?? '',

      // Data pemilik/pengaju klaim
      namaPengambil:
          _readString(json, ['nama_pengambil', 'nama_pemilik']) ??
          _readString(_nestedMap(json, 'user'), ['name', 'nama']) ??
          '',
      emailPengambil:
          _readString(json, ['email_pengambil', 'email_pemilik']) ??
          _readString(_nestedMap(json, 'user'), ['email']) ??
          '',

      // Rincian barang temuan
      kategoriBarang:
          _readString(json, ['kategori_barang', 'nama_kategori']) ??
          _readString(kategori, ['nama_kategori', 'nama']) ??
          _readString(kategoriTemuan, ['nama_kategori', 'nama']) ??
          _readString(barang, ['kategori_barang']) ??
          _readString(barangTemuan, ['kategori_barang']) ??
          '',
      lokasiDitemukan:
          _readString(json, ['lokasi_ditemukan', 'lokasi']) ??
          _readString(barang, ['lokasi_ditemukan', 'lokasi']) ??
          _readString(barangTemuan, ['lokasi_ditemukan', 'lokasi']) ??
          '',
      tanggalTemuan:
          _readString(json, ['tanggal_temuan', 'tanggal_ditemukan']) ??
          _readString(barang, ['tanggal_ditemukan', 'tanggal_temuan']) ??
          _readString(barangTemuan, ['tanggal_ditemukan', 'tanggal_temuan']) ??
          '',
      deskripsiBarang:
          _readString(json, ['deskripsi_barang', 'deskripsi']) ??
          _readString(barang, ['deskripsi', 'keterangan']) ??
          _readString(barangTemuan, ['deskripsi', 'keterangan']) ??
          '',
      warnaDominan:
          _readString(json, ['warna_dominan']) ??
          _readString(barang, ['warna_dominan']) ??
          _readString(barangTemuan, ['warna_dominan']) ??
          '',
      merek:
          _readString(json, ['merek', 'merk']) ??
          _readString(barang, ['merek', 'merk']) ??
          _readString(barangTemuan, ['merek', 'merk']) ??
          '',
      nomorSeri:
          _readString(json, ['nomor_seri']) ??
          _readString(barang, ['nomor_seri']) ??
          _readString(barangTemuan, ['nomor_seri']) ??
          '',

      // Status tambahan
      statusText: _readString(json, ['status_text']) ?? '',
      statusDescription: _readString(json, ['status_description']) ?? '',
      siapDiambil: _readBool(json['siap_diambil']),
      selesai: _readBool(json['selesai']),

      // Kontak petugas
      kontakPosko: _readString(json, ['kontak_posko']) ?? '',
      waUrl: _readString(json, ['wa_url']) ?? '',
      telHref: _readString(json, ['tel_href']) ?? '',
      emailAdmin: _readString(json, ['email_admin']) ?? '',
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

  static Map<String, dynamic> _nestedMap(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
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

  static bool _readBool(dynamic value) {
    if (value == true || value == 1) return true;
    if (value == false || value == 0 || value == null) return false;

    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }

    return false;
  }

  static String _label(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return '-';

    return normalized
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}

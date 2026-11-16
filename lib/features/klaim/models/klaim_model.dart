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
    this.buktiKepemilikan = '',
    this.ciriDariPemilik = '',

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
  final String buktiKepemilikan;
  final String ciriDariPemilik;

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
    final posko = _nestedMap(json, 'posko');
    final poskoTemuan = _nestedMap(barangTemuan, 'posko');
    final poskoBarang = _nestedMap(barang, 'posko');
    final user = _nestedMap(json, 'user');
    final pemohon = _nestedMap(json, 'pemohon');
    final pengaju = _nestedMap(json, 'pengaju');

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
          _readString(json, ['alasan', 'alasan_klaim', 'bukti_kepemilikan', 'keterangan']) ?? '-',
      kontak:
          _readString(json, ['kontak', 'kontak_pelapor', 'no_hp', 'nomor_hp', 'phone']) ??
          _readString(user, ['phone', 'no_hp', 'telepon']) ??
          '-',
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
          _readString(json, ['foto_barang', 'item_image_url', 'image_url', 'foto_url', 'foto', 'gambar']) ??
          _readString(barang, ['foto_barang', 'image_url', 'foto_url', 'foto', 'gambar']) ??
          _readString(barangTemuan, ['foto_barang', 'image_url', 'foto_url', 'foto', 'gambar']) ??
          '',

      // Panduan pengambilan
      kodePengambilan:
          _readString(json, ['kode_pengambilan', 'claim_code']) ?? '',
      namaPosko:
          _readString(json, ['nama_posko', 'posko_name', 'posko']) ??
          _readString(posko, ['nama_posko', 'nama', 'name', 'nama_instansi']) ??
          _readString(poskoTemuan, ['nama_posko', 'nama', 'name']) ??
          _readString(poskoBarang, ['nama_posko', 'nama', 'name']) ??
          '',
      alamatPosko:
          _readString(json, ['alamat_posko', 'posko_address', 'alamat']) ??
          _readString(posko, ['alamat_posko', 'alamat', 'address', 'alamat_lengkap']) ??
          _readString(poskoTemuan, ['alamat_posko', 'alamat']) ??
          _readString(poskoBarang, ['alamat_posko', 'alamat']) ??
          '',
      wilayahPosko:
          _readString(json, ['wilayah_posko', 'posko_region']) ??
          _readString(posko, ['wilayah_posko', 'wilayah', 'kecamatan']) ??
          _readString(poskoTemuan, ['wilayah_posko', 'wilayah', 'kecamatan']) ??
          _readString(poskoBarang, ['wilayah_posko', 'wilayah', 'kecamatan']) ??
          _readString(json, ['wilayah']) ??
          '',
      jamLayanan:
          _readString(json, ['jam_layanan', 'service_hours', 'jam_operasional']) ??
          _readString(posko, ['jam_layanan', 'jam_operasional', 'service_hours']) ??
          _readString(poskoTemuan, ['jam_layanan', 'jam_operasional']) ??
          _readString(poskoBarang, ['jam_layanan', 'jam_operasional']) ??
          '',
      penanggungJawab:
          _readString(json, ['penanggung_jawab', 'person_in_charge', 'petugas']) ??
          _readString(posko, ['penanggung_jawab', 'petugas', 'nama_petugas']) ??
          _readString(poskoTemuan, ['penanggung_jawab', 'petugas']) ??
          _readString(poskoBarang, ['penanggung_jawab', 'petugas']) ??
          '',
      catatanPosko:
          _readString(json, ['catatan_posko', 'pickup_notes', 'catatan']) ??
          _readString(posko, ['catatan_posko', 'catatan']) ??
          '',

      // Data pemilik/pengaju klaim
      namaPengambil:
          _readString(json, ['nama_pengambil', 'nama_pemilik', 'nama_pelapor', 'nama']) ??
          _readString(user, ['name', 'nama', 'nama_lengkap']) ??
          _readString(pemohon, ['name', 'nama', 'nama_lengkap']) ??
          _readString(pengaju, ['name', 'nama', 'nama_lengkap']) ??
          '',
      emailPengambil:
          _readString(json, ['email_pengambil', 'email_pemilik', 'email']) ??
          _readString(user, ['email']) ??
          _readString(pemohon, ['email']) ??
          _readString(pengaju, ['email']) ??
          '',
      buktiKepemilikan:
          _readString(json, ['bukti_kepemilikan', 'alasan_klaim', 'alasan', 'keterangan']) ?? '',
      ciriDariPemilik:
          _readString(json, [
            'ciri_dari_pemilik',
            'bukti_ciri_khusus',
            'ciri_khusus',
            'ciri_unik',
            'ciri',
          ]) ??
          _readString(barangTemuan, ['ciri_khusus', 'ciri_unik']) ??
          _readString(barang, ['ciri_khusus', 'ciri_unik']) ??
          '',

      // Rincian barang temuan
      kategoriBarang:
          _readString(json, ['kategori_barang', 'nama_kategori', 'kategori']) ??
          _readString(kategori, ['nama_kategori', 'nama', 'name']) ??
          _readString(kategoriTemuan, ['nama_kategori', 'nama', 'name']) ??
          _readString(barang, ['kategori_barang', 'nama_kategori', 'kategori']) ??
          _readString(barangTemuan, ['kategori_barang', 'nama_kategori', 'kategori']) ??
          '',
      lokasiDitemukan:
          _readString(json, ['lokasi_ditemukan', 'lokasi', 'tempat_temuan', 'tempat_ditemukan']) ??
          _readString(barang, ['lokasi_ditemukan', 'lokasi', 'tempat_temuan']) ??
          _readString(barangTemuan, ['lokasi_ditemukan', 'lokasi', 'detail_lokasi']) ??
          '',
      tanggalTemuan:
          _readString(json, ['tanggal_temuan', 'tanggal_ditemukan']) ??
          _readString(barang, ['tanggal_ditemukan', 'tanggal_temuan', 'tanggal']) ??
          _readString(barangTemuan, ['tanggal_ditemukan', 'tanggal_temuan', 'tanggal']) ??
          '',
      deskripsiBarang:
          _readString(json, ['deskripsi_barang', 'deskripsi_fisik', 'deskripsi', 'keterangan']) ??
          _readString(barang, ['deskripsi', 'deskripsi_fisik', 'keterangan']) ??
          _readString(barangTemuan, ['deskripsi', 'deskripsi_fisik', 'keterangan']) ??
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
      kontakPosko:
          _readString(json, ['kontak_posko', 'posko_contact', 'no_posko', 'kontak_layanan']) ??
          _readString(posko, ['kontak', 'kontak_layanan', 'no_hp', 'telepon', 'phone']) ??
          _readString(poskoTemuan, ['kontak', 'kontak_layanan', 'no_hp', 'telepon']) ??
          _readString(barangTemuan, ['kontak_posko']) ??
          '',
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

import '../../../core/network/api_client.dart';
import '../models/laporan_model.dart';

enum JenisLaporan { hilang, temuan }

class LaporanRequest {
  const LaporanRequest({
    required this.jenis,
    required this.namaBarang,
    required this.kategoriId,
    required this.wilayahId,
    required this.lokasi,
    required this.deskripsi,
    required this.tanggal,
    // Opsional
    this.warnaDominan,
    this.merek,
    this.nomorSeri,
    this.perkiraanJam,
    this.detailLokasi,
    this.ciriUnik,
    this.noWa,
    this.buktiKepemilikan,
  });

  final JenisLaporan jenis;
  final String namaBarang;
  final String? kategoriId;
  final String wilayahId;
  final String lokasi;
  final String deskripsi;
  final DateTime tanggal;
  final String? warnaDominan;
  final String? merek;
  final String? nomorSeri;
  final dynamic perkiraanJam; // TimeOfDay
  final String? detailLokasi;
  final String? ciriUnik;
  final String? noWa;
  final String? buktiKepemilikan;

  Map<String, dynamic> toJson() {
    final tanggalKey = jenis == JenisLaporan.hilang
        ? 'tanggal_hilang'
        : 'tanggal_ditemukan';

    final data = <String, dynamic>{
      'nama_barang': namaBarang,
      'wilayah_id': _normalizeId(wilayahId),
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      tanggalKey: _formatDate(tanggal),
    };

    if (kategoriId != null) data['kategori_id'] = _normalizeId(kategoriId!);

    // Field opsional — hanya dikirim jika diisi
    if (warnaDominan != null) data['warna_dominan'] = warnaDominan;
    if (merek != null) data['merek'] = merek;
    if (nomorSeri != null) data['nomor_seri'] = nomorSeri;
    if (detailLokasi != null) data['detail_lokasi'] = detailLokasi;
    if (ciriUnik != null) data['ciri_unik'] = ciriUnik;
    if (noWa != null) data['no_wa'] = noWa;
    if (buktiKepemilikan != null) data['bukti_kepemilikan'] = buktiKepemilikan;
    if (perkiraanJam != null) {
      final h = perkiraanJam.hour.toString().padLeft(2, '0');
      final m = perkiraanJam.minute.toString().padLeft(2, '0');
      data['perkiraan_jam'] = '$h:$m';
    }

    return data;
  }

  Object _normalizeId(String value) => int.tryParse(value) ?? value;

  String _formatDate(DateTime v) {
    return '${v.year}-${v.month.toString().padLeft(2, '0')}-${v.day.toString().padLeft(2, '0')}';
  }
}

class LaporanHilangUpdateRequest {
  const LaporanHilangUpdateRequest({
    required this.namaBarang,
    required this.kategoriId,
    required this.wilayahId,
    required this.lokasi,
    required this.deskripsi,
    required this.tanggalHilang,
    this.warnaDominan,
    this.merek,
    this.nomorSeri,
    this.perkiraanJam,
    this.detailLokasi,
    this.ciriUnik,
    this.noWa,
    this.buktiKepemilikan,
  });

  final String namaBarang;
  final String? kategoriId;
  final String wilayahId;
  final String lokasi;
  final String deskripsi;
  final DateTime tanggalHilang;
  final String? warnaDominan;
  final String? merek;
  final String? nomorSeri;
  final dynamic perkiraanJam;
  final String? detailLokasi;
  final String? ciriUnik;
  final String? noWa;
  final String? buktiKepemilikan;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'nama_barang': namaBarang,
      'wilayah_id': _normalizeId(wilayahId),
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      'tanggal_hilang': _formatDate(tanggalHilang),
    };

    if (kategoriId != null) data['kategori_id'] = _normalizeId(kategoriId!);
    if (warnaDominan != null) data['warna_dominan'] = warnaDominan;
    if (merek != null) data['merek'] = merek;
    if (nomorSeri != null) data['nomor_seri'] = nomorSeri;
    if (detailLokasi != null) data['detail_lokasi'] = detailLokasi;
    if (ciriUnik != null) data['ciri_unik'] = ciriUnik;
    if (noWa != null) data['no_wa'] = noWa;
    if (buktiKepemilikan != null) data['bukti_kepemilikan'] = buktiKepemilikan;
    if (perkiraanJam != null) {
      final h = perkiraanJam.hour.toString().padLeft(2, '0');
      final m = perkiraanJam.minute.toString().padLeft(2, '0');
      data['perkiraan_jam'] = '$h:$m';
    }

    return data;
  }

  Object _normalizeId(String value) => int.tryParse(value) ?? value;

  String _formatDate(DateTime v) {
    return '${v.year}-${v.month.toString().padLeft(2, '0')}-${v.day.toString().padLeft(2, '0')}';
  }
}

class LaporanService {
  LaporanService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<LaporanModel>> getLaporan() async => _getLaporanFrom('/laporan');

  Future<List<LaporanModel>> getLaporanPublik() async =>
      _getLaporanFrom('/laporan/publik');

  Future<List<LaporanModel>> searchLaporan(String keyword) async {
    final semua = await getLaporanPublik();

    return semua.where((item) {
      return item.namaBarang.toLowerCase().contains(keyword.toLowerCase());
    }).toList();
  }

  Future<List<LaporanModel>> _getLaporanFrom(String path) async {
    final response = await _apiClient.get(path);
    return _extractList(response)
        .whereType<Map>()
        .map((item) => LaporanModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<LaporanModel> getDetailLaporan({
    required int id,
    required String type,
  }) async {
    final normalizedType = _normalizeType(type);
    final path = switch (normalizedType) {
      'hilang' => '/laporan/hilang/$id',
      'temuan' => '/laporan/temuan/$id',
      _ => throw const ApiException('Jenis laporan tidak dikenali.'),
    };
    final response = await _apiClient.get(path);
    final data = _extractMap(response);
    if (data['id'] == null || data['id'].toString().trim().isEmpty)
      data['id'] = id;
    if (data['type'] == null || data['type'].toString().trim().isEmpty)
      data['type'] = normalizedType;
    return LaporanModel.fromJson(data);
  }

  Future<dynamic> submitLaporan(LaporanRequest request, {String? fotoPath}) {
    final path = request.jenis == JenisLaporan.hilang
        ? '/laporan/hilang'
        : '/laporan/temuan';
    if (_hasFoto(fotoPath)) {
      return _apiClient.multipart(
        'POST',
        path,
        fields: _stringifyFields(request.toJson()),
        files: [_fotoFile(fotoPath!)],
      );
    }
    return _apiClient.post(path, body: request.toJson());
  }

  Future<void> updateLaporanHilang({
    required int id,
    required LaporanHilangUpdateRequest request,
    String? fotoPath,
  }) async {
    if (_hasFoto(fotoPath)) {
      await _apiClient.multipart(
        'PUT',
        '/laporan/hilang/$id',
        fields: _stringifyFields(request.toJson()),
        files: [_fotoFile(fotoPath!)],
      );
      return;
    }
    await _apiClient.put('/laporan/hilang/$id', body: request.toJson());
  }

  Future<void> deleteLaporanHilang({required int id}) async {
    await _apiClient.delete('/laporan/hilang/$id');
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;
    if (response is Map<String, dynamic>) {
      for (final key in ['data', 'laporan', 'laporans', 'items']) {
        final list = _listFromValue(response[key]);
        if (list != null) return list;
      }
    }
    throw const ApiException('Format daftar laporan dari server tidak sesuai.');
  }

  Map<String, dynamic> _extractMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      for (final key in ['data', 'laporan', 'item']) {
        final value = response[key];
        if (value is Map) return Map<String, dynamic>.from(value);
      }
      return response;
    }
    throw const ApiException('Format detail laporan dari server tidak sesuai.');
  }

  List<dynamic>? _listFromValue(dynamic value) {
    if (value is List) return value;
    if (value is Map<String, dynamic>) {
      final nested = value['data'];
      if (nested is List) return nested;
    }
    return null;
  }

  String _normalizeType(String value) {
    final n = value.toLowerCase().trim();
    if (n.contains('hilang')) return 'hilang';
    if (n.contains('temuan') || n.contains('ditemukan')) return 'temuan';
    return n;
  }

  bool _hasFoto(String? p) => p != null && p.trim().isNotEmpty;

  MultipartUploadFile _fotoFile(String path) =>
      MultipartUploadFile(fieldName: 'foto', filePath: path);

  Map<String, String> _stringifyFields(Map<String, dynamic> fields) =>
      fields.map((k, v) => MapEntry(k, v.toString()));
}

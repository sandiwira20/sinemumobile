import 'dart:io';
import '../../../core/network/api_client.dart';
import '../models/klaim_model.dart';

class KlaimService {
  KlaimService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<KlaimModel>> getKlaim() async {
    final response = await _apiClient.get('/klaim');
    final items = _extractList(response);
    return items
        .whereType<Map>()
        .map((item) => KlaimModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<KlaimModel> getDetailKlaim(int id) async {
    final response = await _apiClient.get('/klaim/$id');
    final data = _extractMap(response);
    if (data['id'] == null || data['id'].toString().trim().isEmpty) {
      data['id'] = id;
    }
    return KlaimModel.fromJson(data);
  }

  Future<dynamic> submitKlaimBarangTemuan({
    required int barangId,
    required String kontakPelapor,
    required String buktiKepemilikan,
    required String buktiCiriKhusus,
    required String buktiLokasiSpesifik,
    required String buktiWaktuHilang,
    required List<File> buktiFoto,
    String? laporan_hilang_id,
    String? buktiDetailIsi,
    String? catatan,
  }) async {
    final fields = <String, String>{
      'kontak_pelapor': kontakPelapor,
      'bukti_kepemilikan': buktiKepemilikan,
      'bukti_ciri_khusus': buktiCiriKhusus,
      'bukti_lokasi_spesifik': buktiLokasiSpesifik,
      'bukti_waktu_hilang': buktiWaktuHilang,
      'persetujuan_klaim': '1',
    };

    if (laporan_hilang_id != null && laporan_hilang_id.trim().isNotEmpty) {
      fields['laporan_hilang_id'] = laporan_hilang_id;
    }
    if (buktiDetailIsi != null && buktiDetailIsi.trim().isNotEmpty) {
      fields['bukti_detail_isi'] = buktiDetailIsi;
    }
    if (catatan != null && catatan.trim().isNotEmpty) {
      fields['catatan'] = catatan;
    }

    return _apiClient.postMultipart(
      '/barang-temuan/$barangId/klaim',
      fields: fields,
      files: buktiFoto,
      fileField: 'bukti_foto',
    );
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;
    if (response is Map<String, dynamic>) {
      for (final key in ['data', 'klaim', 'klaims', 'items']) {
        final list = _listFromValue(response[key]);
        if (list != null) return list;
      }
    }
    throw const ApiException('Format riwayat klaim dari server tidak sesuai.');
  }

  Map<String, dynamic> _extractMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      for (final key in ['data', 'klaim', 'item']) {
        final value = response[key];
        if (value is Map) return Map<String, dynamic>.from(value);
      }
      return response;
    }
    throw const ApiException('Format detail klaim dari server tidak sesuai.');
  }

  List<dynamic>? _listFromValue(dynamic value) {
    if (value is List) return value;
    if (value is Map<String, dynamic>) {
      final nestedData = value['data'];
      if (nestedData is List) return nestedData;
    }
    return null;
  }
}
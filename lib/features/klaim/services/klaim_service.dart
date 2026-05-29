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
    String? alasan,
    String? kontak,
  }) {
    final body = <String, dynamic>{};
    final trimmedAlasan = alasan?.trim() ?? '';
    final trimmedKontak = kontak?.trim() ?? '';

    if (trimmedAlasan.isNotEmpty) {
      body['alasan'] = trimmedAlasan;
    }

    if (trimmedKontak.isNotEmpty) {
      body['kontak'] = trimmedKontak;
    }

    return _apiClient.post('/barang-temuan/$barangId/klaim', body: body);
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List) {
      return response;
    }

    if (response is Map<String, dynamic>) {
      for (final key in ['data', 'klaim', 'klaims', 'items']) {
        final list = _listFromValue(response[key]);
        if (list != null) {
          return list;
        }
      }
    }

    throw const ApiException('Format riwayat klaim dari server tidak sesuai.');
  }

  Map<String, dynamic> _extractMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      for (final key in ['data', 'klaim', 'item']) {
        final value = response[key];
        if (value is Map) {
          return Map<String, dynamic>.from(value);
        }
      }

      return response;
    }

    throw const ApiException('Format detail klaim dari server tidak sesuai.');
  }

  List<dynamic>? _listFromValue(dynamic value) {
    if (value is List) {
      return value;
    }

    if (value is Map<String, dynamic>) {
      final nestedData = value['data'];
      if (nestedData is List) {
        return nestedData;
      }
    }

    return null;
  }
}

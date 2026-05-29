import '../../../core/network/api_client.dart';
import '../models/kategori_model.dart';
import '../models/wilayah_model.dart';

class SupportData {
  const SupportData({
    required this.kategoris,
    required this.wilayahs,
  });

  final List<KategoriModel> kategoris;
  final List<WilayahModel> wilayahs;
}

class SupportDataService {
  SupportDataService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<SupportData> getSupportData() async {
    final responses = await Future.wait<dynamic>([
      getKategoris(),
      getWilayahs(),
    ]);

    return SupportData(
      kategoris: responses[0] as List<KategoriModel>,
      wilayahs: responses[1] as List<WilayahModel>,
    );
  }

  Future<List<KategoriModel>> getKategoris() async {
    final response = await _apiClient.get('/kategoris');
    final items = _extractList(response, ['data', 'kategoris', 'kategori']);

    return items
        .whereType<Map>()
        .map((item) => KategoriModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<WilayahModel>> getWilayahs() async {
    final response = await _apiClient.get('/wilayahs');
    final items = _extractList(response, ['data', 'wilayahs', 'wilayah']);

    return items
        .whereType<Map>()
        .map((item) => WilayahModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  List<dynamic> _extractList(dynamic response, List<String> keys) {
    if (response is List) {
      return response;
    }

    if (response is Map<String, dynamic>) {
      for (final key in keys) {
        final value = response[key];
        final list = _listFromValue(value);
        if (list != null) {
          return list;
        }
      }
    }

    throw const ApiException('Format data pendukung dari server tidak sesuai.');
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

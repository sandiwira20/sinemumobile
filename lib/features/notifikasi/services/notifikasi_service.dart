import '../../../core/network/api_client.dart';
import '../models/notifikasi_model.dart';

class NotifikasiService {
  NotifikasiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<NotifikasiModel>> getNotifikasi() async {
    final response = await _apiClient.get('/notifikasi');
    final items = _extractList(response);

    return items
        .whereType<Map>()
        .map(
          (item) => NotifikasiModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> markAsRead(int id) async {
    await _apiClient.patch('/notifikasi/$id/read');
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List) {
      return response;
    }

    if (response is Map<String, dynamic>) {
      for (final key in ['data', 'notifikasi', 'notifications', 'items']) {
        final list = _listFromValue(response[key]);
        if (list != null) {
          return list;
        }
      }
    }

    throw const ApiException('Format notifikasi dari server tidak sesuai.');
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

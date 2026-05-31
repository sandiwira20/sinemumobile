class WilayahModel {
  const WilayahModel({
    required this.id,
    required this.nama,
  });

  final String id;
  final String nama;

  factory WilayahModel.fromJson(Map<String, dynamic> json) {
    final nama =
        _readString(json, [
          'nama',
          'name',
          'nama_wilayah',
          'wilayah',
          'kecamatan',
          'label',
        ]) ??
        'Wilayah';

    return WilayahModel(
      id: _readString(json, ['id', 'wilayah_id', 'value']) ?? nama,
      nama: nama,
    );
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
}

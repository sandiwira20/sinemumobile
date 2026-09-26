class WilayahModel {
  const WilayahModel({
    required this.id,
    required this.nama,
    this.lat,
    this.lng,
  });

  final String id;
  final String nama;
  final double? lat;
  final double? lng;

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
      lat: _readDouble(json['lat']),
      lng: _readDouble(json['lng']),
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

  static double? _readDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }
}
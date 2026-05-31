class KategoriModel {
  const KategoriModel({
    required this.id,
    required this.nama,
  });

  final String id;
  final String nama;

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    final nama =
        _readString(json, [
          'nama',
          'name',
          'nama_kategori',
          'kategori',
          'label',
        ]) ??
        'Kategori';

    return KategoriModel(
      id: _readString(json, ['id', 'kategori_id', 'value']) ?? nama,
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

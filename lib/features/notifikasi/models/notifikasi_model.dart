class NotifikasiModel {
  const NotifikasiModel({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.tanggal,
    required this.dibaca,
  });

  final String id;
  final String judul;
  final String pesan;
  final String tanggal;
  final bool dibaca;

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      id: _readString(json, ['id', 'notifikasi_id', 'notification_id']) ?? '',
      judul: _readString(json, ['judul', 'title', 'subject']) ?? 'Notifikasi',
      pesan:
          _readString(json, [
            'pesan',
            'message',
            'body',
            'isi',
            'description',
          ]) ??
          '-',
      tanggal: _readString(json, ['tanggal', 'created_at', 'time']) ?? '-',
      dibaca: _readReadStatus(json),
    );
  }

  int? get numericId => int.tryParse(id);

  String get tanggalDisplay {
    if (tanggal.length >= 10) {
      return tanggal.substring(0, 10);
    }

    return tanggal;
  }

  NotifikasiModel markRead() {
    return NotifikasiModel(
      id: id,
      judul: judul,
      pesan: pesan,
      tanggal: tanggal,
      dibaca: true,
    );
  }

  static bool _readReadStatus(Map<String, dynamic> json) {
    final explicit = _readDynamic(json, ['dibaca', 'read', 'is_read']);
    if (explicit != null) {
      if (explicit is bool) {
        return explicit;
      }

      if (explicit is num) {
        return explicit == 1;
      }

      final normalized = explicit.toString().toLowerCase().trim();
      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'read' ||
          normalized == 'dibaca' ||
          normalized == 'sudah_dibaca';
    }

    final readAt = _readString(json, ['read_at']);
    return readAt != null && readAt.isNotEmpty;
  }

  static dynamic _readDynamic(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data.containsKey(key)) {
        return data[key];
      }
    }

    return null;
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

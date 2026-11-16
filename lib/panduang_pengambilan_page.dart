import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'core/config/api_config.dart';

import 'user_data.dart';
import 'features/klaim/services/klaim_service.dart';
import 'features/laporan/services/laporan_service.dart';

class PanduanPengambilanPage extends StatefulWidget {
  const PanduanPengambilanPage({
    super.key,
    required this.namaBarang,
    required this.wilayah,
    required this.nomorKlaim,
    required this.statusKlaim,
    required this.kontak,
    required this.tanggal,
    required this.keterangan,
    this.fotoBarang = '',
    this.kodePengambilan = '',
    this.namaPosko = '',
    this.alamatPosko = '',
    this.wilayahPosko = '',
    this.jamLayanan = '',
    this.penanggungJawab = '',
    this.catatanPosko = '',
    this.kontakPosko = '',
    this.namaPengambil = '',
    this.emailPengambil = '',
    this.buktiKepemilikan = '',
    this.ciriKhusus = '',
    this.ciriDariPemilik = '',
    this.deskripsiBarang = '',
    this.lokasiDitemukan = '',
    this.kategoriBarang = '',
    this.tanggalTemuan = '',
  });

  final String namaBarang;
  final String wilayah;
  final String nomorKlaim;
  final String statusKlaim;
  final String kontak;
  final String tanggal;
  final String keterangan;

  // Data tambahan agar tampilan Flutter mengikuti tiket versi web.
  final String fotoBarang;
  final String kodePengambilan;
  final String namaPosko;
  final String alamatPosko;
  final String wilayahPosko;
  final String jamLayanan;
  final String penanggungJawab;
  final String catatanPosko;
  final String kontakPosko;
  final String namaPengambil;
  final String emailPengambil;
  final String buktiKepemilikan;
  final String ciriKhusus;
  final String ciriDariPemilik;
  final String deskripsiBarang;
  final String lokasiDitemukan;
  final String kategoriBarang;
  final String tanggalTemuan;

  @override
  State<PanduanPengambilanPage> createState() => _PanduanPengambilanPageState();
}

class _PanduanPengambilanPageState extends State<PanduanPengambilanPage> {
  late String _namaBarang;
  late String _wilayah;
  late String _nomorKlaim;
  late String _statusKlaim;
  late String _kontakPengambil;
  late String _fotoBarang;
  late String _kodePengambilan;
  late String _namaPosko;
  late String _alamatPosko;
  late String _wilayahPosko;
  late String _jamLayanan;
  late String _penanggungJawab;
  late String _catatanPosko;
  late String _kontakPosko;
  late String _namaPengambil;
  late String _emailPengambil;
  late String _buktiKepemilikan;
  late String _ciriDariPemilik;
  late String _deskripsiBarang;
  late String _lokasiDitemukan;
  late String _kategoriBarang;
  late String _tanggalTemuan;

  bool _isMembuatPdf = false;

  static const List<String> _bulanIndo = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _namaBarang = widget.namaBarang;
    _wilayah = widget.wilayah;
    _nomorKlaim = widget.nomorKlaim;
    _statusKlaim = widget.statusKlaim;
    _kontakPengambil = widget.kontak.trim().isNotEmpty && widget.kontak.trim() != '-'
        ? widget.kontak.trim()
        : UserData.phone.trim();
    _fotoBarang = widget.fotoBarang;
    _kodePengambilan = widget.kodePengambilan;
    _namaPosko = widget.namaPosko;
    _alamatPosko = widget.alamatPosko;
    _wilayahPosko = widget.wilayahPosko.trim().isNotEmpty
        ? widget.wilayahPosko.trim()
        : widget.wilayah.trim();
    _jamLayanan = widget.jamLayanan.trim().isNotEmpty
        ? widget.jamLayanan.trim()
        : 'Senin - Jumat, 08:30 - 15:30 WIB';
    _penanggungJawab = widget.penanggungJawab.trim().isNotEmpty
        ? widget.penanggungJawab.trim()
        : (_wilayahPosko.isNotEmpty ? _wilayahPosko : 'Jatibarang');
    _catatanPosko = widget.catatanPosko;
    _kontakPosko = widget.kontakPosko.trim().isNotEmpty
        ? widget.kontakPosko.trim()
        : '085776939837';
    _namaPengambil = widget.namaPengambil.trim().isNotEmpty
        ? widget.namaPengambil.trim()
        : UserData.nama.trim();
    _emailPengambil = widget.emailPengambil.trim().isNotEmpty
        ? widget.emailPengambil.trim()
        : UserData.email.trim();
    _buktiKepemilikan = widget.buktiKepemilikan.trim().isNotEmpty
        ? widget.buktiKepemilikan.trim()
        : (widget.keterangan != '-' ? widget.keterangan.trim() : '');
    _ciriDariPemilik = widget.ciriDariPemilik.trim().isNotEmpty
        ? widget.ciriDariPemilik.trim()
        : widget.ciriKhusus.trim();
    _deskripsiBarang = widget.deskripsiBarang;
    _lokasiDitemukan = widget.lokasiDitemukan;
    _kategoriBarang = widget.kategoriBarang;
    _tanggalTemuan = widget.tanggalTemuan;

    _fetchMissingData();
  }

  Future<void> _fetchMissingData() async {
    final numericId = int.tryParse(_nomorKlaim.replaceAll(RegExp(r'[^0-9]'), ''));
    if (numericId == null) return;

    try {
      final klaimService = KlaimService();
      final detail = await klaimService.getDetailKlaim(numericId);

      if (!mounted) return;
      setState(() {
        if (_namaBarang.isEmpty || _namaBarang == '-' || _namaBarang == 'Tanpa nama barang') {
          if (detail.namaBarang.isNotEmpty) _namaBarang = detail.namaBarang;
        }
        if (_statusKlaim.isEmpty || _statusKlaim == '-') {
          if (detail.statusLabel.isNotEmpty) _statusKlaim = detail.statusLabel;
        }
        if (_fotoBarang.isEmpty && detail.fotoBarang.isNotEmpty) {
          _fotoBarang = detail.fotoBarang;
        }
        if (_kategoriBarang.isEmpty && detail.kategoriBarang.isNotEmpty) {
          _kategoriBarang = detail.kategoriBarang;
        }
        if (_lokasiDitemukan.isEmpty && detail.lokasiDitemukan.isNotEmpty) {
          _lokasiDitemukan = detail.lokasiDitemukan;
        }
        if (_tanggalTemuan.isEmpty && detail.tanggalTemuan.isNotEmpty) {
          _tanggalTemuan = detail.tanggalTemuan;
        }
        if (_deskripsiBarang.isEmpty && detail.deskripsiBarang.isNotEmpty) {
          _deskripsiBarang = detail.deskripsiBarang;
        }
        if (_ciriDariPemilik.isEmpty && detail.ciriDariPemilik.isNotEmpty) {
          _ciriDariPemilik = detail.ciriDariPemilik;
        }
        if (_buktiKepemilikan.isEmpty && detail.buktiKepemilikan.isNotEmpty) {
          _buktiKepemilikan = detail.buktiKepemilikan;
        }
        if (_namaPengambil.isEmpty && detail.namaPengambil.isNotEmpty) {
          _namaPengambil = detail.namaPengambil;
        }
        if (_emailPengambil.isEmpty && detail.emailPengambil.isNotEmpty) {
          _emailPengambil = detail.emailPengambil;
        }
        if ((_kontakPengambil.isEmpty || _kontakPengambil == '-') && detail.kontak.isNotEmpty) {
          _kontakPengambil = detail.kontak;
        }
        if (_namaPosko.isEmpty && detail.namaPosko.isNotEmpty) {
          _namaPosko = detail.namaPosko;
        }
        if (_alamatPosko.isEmpty && detail.alamatPosko.isNotEmpty) {
          _alamatPosko = detail.alamatPosko;
        }
        if (_wilayahPosko.isEmpty && detail.wilayahPosko.isNotEmpty) {
          _wilayahPosko = detail.wilayahPosko;
        }
        if (_jamLayanan.isEmpty && detail.jamLayanan.isNotEmpty) {
          _jamLayanan = detail.jamLayanan;
        }
        if (_penanggungJawab.isEmpty && detail.penanggungJawab.isNotEmpty) {
          _penanggungJawab = detail.penanggungJawab;
        }
        if (_kontakPosko.isEmpty && detail.kontakPosko.isNotEmpty) {
          _kontakPosko = detail.kontakPosko;
        }
      });

      final bId = int.tryParse(detail.barangId.replaceAll(RegExp(r'[^0-9]'), ''));
      if (bId != null &&
          (_fotoBarang.isEmpty ||
              _kategoriBarang.isEmpty ||
              _lokasiDitemukan.isEmpty ||
              _tanggalTemuan.isEmpty)) {
        try {
          final laporanService = LaporanService();
          final lapDetail =
              await laporanService.getDetailLaporan(id: bId, type: 'temuan');
          if (!mounted) return;
          setState(() {
            if (_fotoBarang.isEmpty && lapDetail.imageUrl.isNotEmpty) {
              _fotoBarang = lapDetail.imageUrl;
            }
            if (_kategoriBarang.isEmpty && lapDetail.kategori != '-') {
              _kategoriBarang = lapDetail.kategori;
            }
            if (_lokasiDitemukan.isEmpty && lapDetail.lokasi != '-') {
              _lokasiDitemukan = lapDetail.lokasi;
            }
            if (_tanggalTemuan.isEmpty && lapDetail.tanggal != '-') {
              _tanggalTemuan = lapDetail.tanggal;
            }
            if (_deskripsiBarang.isEmpty && lapDetail.deskripsi != '-') {
              _deskripsiBarang = lapDetail.deskripsi;
            }
          });
        } catch (_) {}
      }
    } catch (_) {}
  }

  String _normalizeImageUrl(String url) {
    final value = url.trim();
    if (value.isEmpty) return '';

    const baseUrl = 'https://sinemu.my.id';

    if (value.startsWith('http://192.168.') ||
        value.startsWith('http://10.0.2.2') ||
        value.startsWith('http://localhost')) {
      final uri = Uri.tryParse(value);
      if (uri != null) {
        return '$baseUrl${uri.path}';
      }
    }

    if (value.startsWith('https://') || value.startsWith('http://')) {
      return value;
    }

    var path = value.replaceAll('\\', '/');
    while (path.startsWith('/')) {
      path = path.substring(1);
    }

    if (path.startsWith('public/')) {
      path = path.substring(7);
    }
    if (path.startsWith('storage/')) {
      path = path.substring(8);
    }

    if (path.startsWith('barang-temuan/') ||
        path.startsWith('barang-hilang/') ||
        path.startsWith('verifikasi-klaim/')) {
      return '$baseUrl/media/$path';
    }

    return '$baseUrl/storage/$path';
  }


final baseUrl = ApiConfig.rootUrl;

Future<pw.ImageProvider?> _fetchPdfImage(String rawUrl) async {
  final normalized = _normalizeImageUrl(rawUrl);
  if (normalized.isEmpty) return null;

    final candidates = <String>[
      normalized,
      if (normalized.startsWith('http://'))
        normalized.replaceFirst('http://', 'https://'),
      if (normalized.contains('/media/'))
        normalized.replaceFirst('/media/', '/storage/'),
      if (normalized.contains('/storage/'))
        normalized.replaceFirst('/storage/', '/media/'),
    ];

    for (final url in candidates) {
      try {
        final res =
            await http.get(Uri.parse(url)).timeout(const Duration(seconds: 6));
        if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
          return pw.MemoryImage(res.bodyBytes);
        }
      } catch (_) {}
    }

    try {
      return await networkImage(normalized);
    } catch (_) {
      return null;
    }
  }

  Future<pw.MemoryImage?> _loadLogoAsset() async {
    try {
      final bytes = await rootBundle.load('assets/images/logosinemu.png');
      return pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  String get _kode {
    if (_kodePengambilan.trim().isNotEmpty) {
      final k = _kodePengambilan.trim();
      return k.startsWith('#') ? k : '#$k';
    }
    final raw = _nomorKlaim.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isNotEmpty) {
      return '#KLM-${raw.padLeft(5, '0')}';
    }
    return _nomorKlaim.trim().isNotEmpty ? _nomorKlaim.trim() : '#KLM-00001';
  }

  String get _status {
    final value = _statusKlaim.trim().toLowerCase();
    if (value.contains('selesai') || value.contains('diserahkan')) {
      return 'Sudah Diserahkan (Selesai)';
    }
    if (value == 'disetujui' || value.contains('siap diambil')) {
      return 'Siap Diambil';
    }
    if (value.contains('tolak')) return 'Tidak Disetujui';
    return _statusKlaim.trim().isEmpty ? 'Menunggu Tinjauan' : _statusKlaim;
  }

  String get _statusDokumenText {
    final value = _status.toLowerCase();
    if (value.contains('siap diambil') || value.contains('disetujui')) {
      return 'SIAP DIAMBIL (TERVERIFIKASI RESMI)';
    }
    if (value.contains('selesai') || value.contains('diserahkan')) {
      return 'SUDAH DISERAHKAN (SELESAI)';
    }
    if (value.contains('tolak')) {
      return 'TIDAK DISETUJUI';
    }
    return _status.toUpperCase();
  }

  bool get _isReady {
    final value = _status.toLowerCase();
    return value.contains('siap diambil') || value == 'disetujui';
  }

  bool get _isCompleted => _status.toLowerCase().contains('selesai');

  String _val(String value) => value.trim().isEmpty ? '-' : value.trim();

  String _formatTanggalCetak(DateTime dt) {
    final d = dt.day;
    final m = _bulanIndo[dt.month];
    final y = dt.year;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d $m $y, $hh:$mm WIB';
  }

  String _formatTanggalIndo(DateTime dt) {
    final d = dt.day;
    final m = _bulanIndo[dt.month];
    final y = dt.year;
    return '$d $m $y';
  }

  String _formatTanggalString(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == '-') return '-';
    try {
      final dt = DateTime.parse(trimmed);
      return _formatTanggalIndo(dt);
    } catch (_) {
      final parts = trimmed.split('-');
      if (parts.length >= 3 && parts[0].length == 4) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final dStr = parts[2].split(' ')[0].split('T')[0];
        final d = int.tryParse(dStr);
        if (y != null && m != null && d != null && m >= 1 && m <= 12) {
          return '$d ${_bulanIndo[m]} $y';
        }
      }
      return trimmed;
    }
  }

  Future<void> _salinKode() async {
    await Clipboard.setData(ClipboardData(text: _kode));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kode pengambilan berhasil disalin.')),
    );
  }

  Future<void> _cetakBuktiKlaim() async {
    if (_isMembuatPdf) return;
    setState(() => _isMembuatPdf = true);

    try {
      final itemImage = await _fetchPdfImage(_fotoBarang);
      final logoImage = await _loadLogoAsset();

      final pdf = pw.Document();
      final navy = PdfColor.fromHex('#0F172A');
      final slate = PdfColor.fromHex('#475569');
      final pale = PdfColor.fromHex('#F8FAFC');
      final border = PdfColor.fromHex('#CBD5E1');
      final blue = PdfColor.fromHex('#1E40AF');

      final now = DateTime.now();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // 1. Header (Logo + Subtitle di kiri, Registrasi + Tanggal di kanan)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (logoImage != null)
                          pw.Image(logoImage, height: 26, fit: pw.BoxFit.contain)
                        else
                          pw.Text(
                            'SiNemu',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: navy,
                            ),
                          ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Sistem Informasi Pengelolaan Barang Hilang & Temuan',
                          style: pw.TextStyle(fontSize: 7.5, color: slate),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.RichText(
                          text: pw.TextSpan(
                            children: [
                              pw.TextSpan(
                                text: 'Nomor Registrasi: ',
                                style: pw.TextStyle(fontSize: 7.5, color: slate),
                              ),
                              pw.TextSpan(
                                text: _kode,
                                style: pw.TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: navy,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Tanggal Cetak: ${_formatTanggalCetak(now)}',
                          style: pw.TextStyle(fontSize: 7.5, color: slate),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Divider(color: navy, thickness: 1.5),
                pw.SizedBox(height: 8),

                // 2. Judul Dokumen
                pw.Center(
                  child: pw.Text(
                    'BUKTI PENGAMBILAN BARANG TEMUAN',
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: navy,
                    ),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text(
                    'Dokumen Serah Terima Resmi Posko Layanan SiNemu',
                    style: pw.TextStyle(fontSize: 7.5, color: slate),
                  ),
                ),
                pw.SizedBox(height: 8),

                // 3. Status Dokumen Bar
                pw.Container(
                  width: double.infinity,
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: pw.BoxDecoration(
                    color: pale,
                    border: pw.Border.all(color: border),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'STATUS DOKUMEN:',
                        style: pw.TextStyle(
                          fontSize: 7.5,
                          fontWeight: pw.FontWeight.bold,
                          color: navy,
                        ),
                      ),
                      pw.Text(
                        _statusDokumenText,
                        style: pw.TextStyle(
                          fontSize: 7.5,
                          fontWeight: pw.FontWeight.bold,
                          color: blue,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),

                // 4. Dua Kolom Berdampingan: Section I & Section II
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Kolom Kiri: I. RINCIAN BARANG TEMUAN
                    pw.Expanded(
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: border),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              width: double.infinity,
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              decoration: pw.BoxDecoration(
                                color: pale,
                                border: pw.Border(
                                    bottom: pw.BorderSide(color: border)),
                              ),
                              child: pw.Text(
                                'I. RINCIAN BARANG TEMUAN',
                                style: pw.TextStyle(
                                  fontSize: 7.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: navy,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(7),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        _pdfRowItem(
                                            'Nama Barang', _val(_namaBarang),
                                            isBold: true),
                                        _pdfRowItem(
                                            'Kategori', _val(_kategoriBarang)),
                                        _pdfRowItem('Lokasi Ditemukan',
                                            _val(_lokasiDitemukan)),
                                        _pdfRowItem('Tanggal Temuan',
                                            _formatTanggalString(_tanggalTemuan)),
                                        _pdfRowItem('Deskripsi Fisik',
                                            _val(_deskripsiBarang)),
                                      ],
                                    ),
                                  ),
                                  pw.SizedBox(width: 6),
                                  pw.Container(
                                    width: 62,
                                    height: 62,
                                    decoration: pw.BoxDecoration(
                                      color: pale,
                                      border: pw.Border.all(color: border),
                                    ),
                                    child: itemImage != null
                                        ? pw.ClipRect(
                                            child: pw.Image(itemImage,
                                                fit: pw.BoxFit.cover),
                                          )
                                        : pw.Center(
                                            child: pw.Text(
                                              'Foto Barang',
                                              style: pw.TextStyle(
                                                  fontSize: 6, color: slate),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),

                    // Kolom Kanan: II. RINCIAN PEMILIK / PENGAJU KLAIM
                    pw.Expanded(
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: border),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              width: double.infinity,
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              decoration: pw.BoxDecoration(
                                color: pale,
                                border: pw.Border(
                                    bottom: pw.BorderSide(color: border)),
                              ),
                              child: pw.Text(
                                'II. RINCIAN PEMILIK / PENGAJU KLAIM',
                                style: pw.TextStyle(
                                  fontSize: 7.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: navy,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(7),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _pdfRowItem(
                                      'Nama Pengambil', _val(_namaPengambil),
                                      isBold: true),
                                  _pdfRowItem('No. Telepon / WA',
                                      _val(_kontakPengambil)),
                                  _pdfRowItem('Email Terdaftar',
                                      _val(_emailPengambil)),
                                  _pdfRowItem('Bukti Kepemilikan',
                                      _val(_buktiKepemilikan)),
                                  _pdfRowItem('Ciri dari Pemilik',
                                      _val(_ciriDariPemilik)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),

                // 5. Full Width: III. INFORMASI POSKO PENYERAHAN BARANG
                pw.Container(
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: border),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: pw.BoxDecoration(
                          color: pale,
                          border:
                              pw.Border(bottom: pw.BorderSide(color: border)),
                        ),
                        child: pw.Text(
                          'III. INFORMASI POSKO PENYERAHAN BARANG',
                          style: pw.TextStyle(
                            fontSize: 7.5,
                            fontWeight: pw.FontWeight.bold,
                            color: navy,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(7),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _pdfPoskoBlock('Nama Posko / Instansi:',
                                      _val(_namaPosko),
                                      isBold: true),
                                  _pdfPoskoBlock('Alamat Lengkap Posko:',
                                      _val(_alamatPosko)),
                                  _pdfPoskoBlock('Petugas Penanggung Jawab:',
                                      _val(_penanggungJawab)),
                                ],
                              ),
                            ),
                            pw.SizedBox(width: 14),
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _pdfPoskoBlock('Wilayah / Kecamatan:',
                                      _val(_wilayahPosko.isNotEmpty ? _wilayahPosko : _wilayah)),
                                  _pdfPoskoBlock('Jam Layanan Operasional:',
                                      _val(_jamLayanan),
                                      isBold: true),
                                  _pdfPoskoBlock('Kontak Layanan Posko:',
                                      _val(_kontakPosko)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),

                // 6. Catatan Pengambilan Box
                pw.Container(
                  width: double.infinity,
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: pale,
                    border: pw.Border(
                      top: pw.BorderSide(color: border),
                      right: pw.BorderSide(color: border),
                      bottom: pw.BorderSide(color: border),
                      left: pw.BorderSide(color: navy, width: 3),
                    ),
                  ),
                  child: pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'Catatan Pengambilan: ',
                          style: pw.TextStyle(
                            fontSize: 7,
                            fontWeight: pw.FontWeight.bold,
                            color: navy,
                          ),
                        ),
                        pw.TextSpan(
                          text:
                              'Wajib membawa kartu identitas asli (KTP/KTM) dan menunjukkan bukti tiket ini saat pengambilan barang di lokasi posko layanan.',
                          style: pw.TextStyle(fontSize: 7, color: navy),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 22),

                // 7. Area Tanda Tangan
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 24),
                    child: pw.Text(
                      'Indramayu, ${_formatTanggalIndo(now)}',
                      style: pw.TextStyle(fontSize: 7.5, color: navy),
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'Penerima / Pemilik Barang,',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 7.5, color: navy),
                          ),
                          pw.SizedBox(height: 42),
                          pw.Text(
                            '( ${_val(_namaPengambil)} )',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 7.5,
                              fontWeight: pw.FontWeight.bold,
                              color: navy,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Container(
                            width: 150,
                            height: 0.8,
                            color: PdfColors.black,
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Tanda Tangan & Nama Terang',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 6.5, color: slate),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 40),
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'Petugas Penyerah Posko,',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 7.5, color: navy),
                          ),
                          pw.SizedBox(height: 42),
                          pw.Text(
                            '( ${_val(_penanggungJawab)} )',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 7.5,
                              fontWeight: pw.FontWeight.bold,
                              color: navy,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Container(
                            width: 150,
                            height: 0.8,
                            color: PdfColors.black,
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Tanda Tangan & Cap Posko',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 6.5, color: slate),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (_) async => pdf.save(),
        name: 'Bukti_Pengambilan_${_kode.replaceAll('#', '')}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat PDF: $e')));
    } finally {
      if (mounted) setState(() => _isMembuatPdf = false);
    }
  }

  pw.Widget _pdfRowItem(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 64,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                  fontSize: 7, color: PdfColor.fromHex('#0F172A')),
            ),
          ),
          pw.Text(': ',
              style: pw.TextStyle(
                  fontSize: 7, color: PdfColor.fromHex('#0F172A'))),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: PdfColor.fromHex('#0F172A'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfPoskoBlock(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3.5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
                fontSize: 6.5, color: PdfColor.fromHex('#475569')),
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColor.fromHex('#0F172A'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF357ABD)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _val(value),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requirementCard(String number, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF357ABD),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _isReady
        ? const Color(0xFF15803D)
        : _isCompleted
            ? const Color(0xFF2563EB)
            : _status.toLowerCase().contains('tolak')
                ? const Color(0xFFB91C1C)
                : const Color(0xFFB45309);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          'Tiket Pengambilan Barang',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tiket & Instruksi Pengambilan Barang',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tunjukkan tiket dan identitas diri Anda di lokasi posko layanan untuk verifikasi dan serah terima fisik barang.',
              style: TextStyle(color: Color(0xFF64748B), height: 1.45),
            ),
            const SizedBox(height: 18),

            // Banner bukti pengambilan dan kode tiket.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.task_alt,
                        color: Color(0xFF357ABD),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'BUKTI PENGAMBILAN BARANG',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          _status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'KODE PENGAMBILAN BARANG',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          _kode,
                          style: const TextStyle(
                            fontSize: 25,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _salinKode,
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Salin'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Tunjukkan kode ini kepada petugas posko bersama kartu identitas diri yang sah.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _infoCard(
              title: 'I. RINCIAN BARANG TEMUAN',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_fotoBarang.trim().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _normalizeImageUrl(_fotoBarang),
                        width: double.infinity,
                        height: 190,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          width: double.infinity,
                          color: const Color(0xFFF1F5F9),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: 30,
                                color: Color(0xFF94A3B8),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Foto barang gagal dimuat',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            color: Color(0xFF94A3B8),
                            size: 30,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Foto barang belum tersedia',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  _infoRow(
                    Icons.inventory_2_outlined,
                    'Nama Barang',
                    _namaBarang,
                  ),
                  _infoRow(
                    Icons.category_outlined,
                    'Kategori',
                    _kategoriBarang,
                  ),
                  _infoRow(
                    Icons.location_on_outlined,
                    'Lokasi Ditemukan',
                    _lokasiDitemukan,
                  ),
                  _infoRow(
                    Icons.event_outlined,
                    'Tanggal Temuan',
                    _formatTanggalString(_tanggalTemuan),
                  ),
                  _infoRow(
                    Icons.notes_outlined,
                    'Deskripsi Fisik',
                    _deskripsiBarang,
                  ),
                ],
              ),
            ),

            _infoCard(
              title: 'II. RINCIAN PEMILIK / PENGAJU KLAIM',
              child: Column(
                children: [
                  _infoRow(
                    Icons.person_outline,
                    'Nama Pengambil',
                    _namaPengambil,
                  ),
                  _infoRow(
                    Icons.phone_outlined,
                    'No. Telepon / WA',
                    _kontakPengambil,
                  ),
                  _infoRow(
                    Icons.email_outlined,
                    'Email Terdaftar',
                    _emailPengambil,
                  ),
                  _infoRow(
                    Icons.verified_outlined,
                    'Bukti Kepemilikan',
                    _buktiKepemilikan,
                  ),
                  _infoRow(
                    Icons.fact_check_outlined,
                    'Ciri dari Pemilik',
                    _ciriDariPemilik,
                  ),
                ],
              ),
            ),

            _infoCard(
              title: 'III. INFORMASI POSKO PENYERAHAN BARANG',
              child: Column(
                children: [
                  _infoRow(
                    Icons.apartment_outlined,
                    'Nama Posko / Instansi',
                    _namaPosko,
                  ),
                  _infoRow(
                    Icons.map_outlined,
                    'Alamat Lengkap',
                    _alamatPosko,
                  ),
                  _infoRow(
                    Icons.location_city_outlined,
                    'Wilayah / Kecamatan',
                    _wilayahPosko.isNotEmpty ? _wilayahPosko : _wilayah,
                  ),
                  _infoRow(
                    Icons.access_time_outlined,
                    'Jam Layanan Operasional',
                    _jamLayanan,
                  ),
                  _infoRow(
                    Icons.badge_outlined,
                    'Petugas Penanggung Jawab',
                    _penanggungJawab,
                  ),
                  _infoRow(
                    Icons.phone_in_talk_outlined,
                    'Kontak Layanan Posko',
                    _kontakPosko,
                  ),
                  if (_catatanPosko.trim().isNotEmpty)
                    _infoRow(
                      Icons.info_outline,
                      'Catatan Posko',
                      _catatanPosko,
                    ),
                ],
              ),
            ),

            _sectionTitle(
              Icons.assignment_turned_in_outlined,
              'IV. Syarat Penyerahan Fisik Barang',
              'Wajib dipenuhi saat pengambilan di posko layanan:',
            ),
            _requirementCard(
              '1',
              'Membawa Identitas Asli yang Sah',
              'Bawa KTM (Kartu Tanda Mahasiswa), KTP, atau SIM asli atas nama ${_val(_namaPengambil)} sesuai profil akun SiNemu.',
            ),
            _requirementCard(
              '2',
              'Menunjukkan Kode Tiket Klaim',
              'Tunjukkan kode tiket $_kode pada layar smartphone Anda kepada petugas loket posko.',
            ),
            _requirementCard(
              '3',
              'Pencocokan Ciri Khusus Bersama Petugas',
              'Petugas akan mencocokkan ciri khusus, detail fisik, nomor seri, atau isi barang temuan yang Anda laporkan.',
            ),
            _requirementCard(
              '4',
              'Konfirmasi & Penandatanganan Berita Acara',
              'Setelah barang diverifikasi sesuai, petugas dan Anda menandatangani tanda terima/berita acara serah terima barang di tempat.',
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFB45309)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Catatan Pengambilan: Wajib membawa kartu identitas asli dan menunjukkan bukti tiket ini saat pengambilan barang di lokasi posko layanan.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isMembuatPdf ? null : _cetakBuktiKlaim,
                icon: _isMembuatPdf
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
                label: Text(
                  _isMembuatPdf
                      ? 'Menyiapkan PDF...'
                      : 'Cetak Tiket / Bukti Pengambilan (PDF)',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF357ABD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

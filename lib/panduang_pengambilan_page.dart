import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
    this.namaPengambil = '',
    this.emailPengambil = '',
    this.buktiKepemilikan = '',
    this.ciriKhusus = '',
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
  final String namaPengambil;
  final String emailPengambil;
  final String buktiKepemilikan;
  final String ciriKhusus;
  final String deskripsiBarang;
  final String lokasiDitemukan;
  final String kategoriBarang;
  final String tanggalTemuan;

  @override
  State<PanduanPengambilanPage> createState() => _PanduanPengambilanPageState();
}

class _PanduanPengambilanPageState extends State<PanduanPengambilanPage> {
  bool _isMembuatPdf = false;

  String _normalizeImageUrl(String url) {
  final value = url.trim();

  if (value.isEmpty) return '';

  // URL lengkap dari backend jangan diubah.
  if (value.startsWith('https://') ||
      value.startsWith('http://')) {
    return value;
  }

  const baseUrl = 'http://192.168.1.6:8000';

  // Hapus prefix storage/ atau public/ jika ada.
  var path = value.replaceAll('\\', '/');

  if (path.startsWith('public/')) {
    path = path.substring(7);
  }

  if (path.startsWith('storage/')) {
    path = path.substring(8);
  }

  // Path foto harus diarahkan sesuai lokasi penyimpanan.
  if (path.startsWith('barang-temuan/') ||
      path.startsWith('barang-hilang/') ||
      path.startsWith('verifikasi-klaim/')) {
    return '$baseUrl/media/$path';
  }

  return '$baseUrl/storage/$path';
}

  String get _kode => widget.kodePengambilan.trim().isNotEmpty
      ? widget.kodePengambilan.trim()
      : widget.nomorKlaim.trim();

  String get _status {
    final value = widget.statusKlaim.trim().toLowerCase();
    if (value.contains('selesai') || value.contains('diserahkan')) {
      return 'Sudah Diserahkan (Selesai)';
    }
    if (value == 'disetujui' || value.contains('siap diambil')) {
      return 'Siap Diambil';
    }
    if (value.contains('tolak')) return 'Tidak Disetujui';
    return widget.statusKlaim.trim().isEmpty
        ? 'Menunggu Tinjauan'
        : widget.statusKlaim;
  }

  bool get _isReady {
    final value = _status.toLowerCase();
    return value.contains('siap diambil') || value == 'disetujui';
  }

  bool get _isCompleted => _status.toLowerCase().contains('selesai');

  String _value(String value) => value.trim().isEmpty ? '-' : value.trim();

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
      pw.ImageProvider? itemImage;
      if (widget.fotoBarang.trim().isNotEmpty) {
        try {
          itemImage = await networkImage(widget.fotoBarang.trim());
        } catch (_) {
          itemImage = null;
        }
      }

      final pdf = pw.Document();
      final navy = PdfColor.fromHex('#0F172A');
      final slate = PdfColor.fromHex('#475569');
      final pale = PdfColor.fromHex('#F8FAFC');
      final border = PdfColor.fromHex('#CBD5E1');
      final blue = PdfColor.fromHex('#357ABD');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (context) => [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SiNemu',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Sistem Informasi Pengelolaan Barang Hilang & Temuan',
                      style: pw.TextStyle(fontSize: 8, color: slate),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'NOMOR REGISTRASI',
                      style: pw.TextStyle(fontSize: 7, color: slate),
                    ),
                    pw.Text(
                      _kode,
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    pw.Text(
                      'Tanggal cetak: ${DateTime.now().day.toString().padLeft(2, '0')}-'
                      '${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}',
                      style: pw.TextStyle(fontSize: 8, color: slate),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: navy, thickness: 1.5),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'BUKTI PENGAMBILAN BARANG TEMUAN',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: navy,
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Dokumen Serah Terima Posko Layanan SiNemu',
                style: pw.TextStyle(fontSize: 8, color: slate),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: pw.BoxDecoration(
                color: pale,
                border: pw.Border.all(color: border),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'STATUS DOKUMEN',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: slate,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    _status.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: navy,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            _pdfSectionTitle('I. RINCIAN BARANG TEMUAN', navy, pale, border),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(9),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: border),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (itemImage != null)
                    pw.Container(
                      width: 105,
                      height: 105,
                      margin: const pw.EdgeInsets.only(right: 10),
                      child: pw.Image(itemImage, fit: pw.BoxFit.cover),
                    ),
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        _pdfRow('Nama Barang', widget.namaBarang),
                        _pdfRow('Kategori', _value(widget.kategoriBarang)),
                        _pdfRow(
                          'Lokasi Ditemukan',
                          _value(widget.lokasiDitemukan),
                        ),
                        _pdfRow('Tanggal Temuan', _value(widget.tanggalTemuan)),
                        _pdfRow('Wilayah', widget.wilayah),
                        _pdfRow(
                          'Deskripsi Fisik',
                          _value(widget.deskripsiBarang),
                        ),
                        _pdfRow('Ciri Khusus', _value(widget.ciriKhusus)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 9),
            _pdfSectionTitle(
              'II. RINCIAN PEMILIK / PENGAJU KLAIM',
              navy,
              pale,
              border,
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(9),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: border),
              ),
              child: pw.Column(
                children: [
                  _pdfRow('Nama Pengambil', _value(widget.namaPengambil)),
                  _pdfRow('No. Telepon / WA', widget.kontak),
                  _pdfRow('Email Terdaftar', _value(widget.emailPengambil)),
                  _pdfRow('Tanggal Klaim', widget.tanggal),
                  _pdfRow(
                    'Bukti Kepemilikan',
                    _value(
                      widget.buktiKepemilikan.isNotEmpty
                          ? widget.buktiKepemilikan
                          : widget.keterangan,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 9),
            _pdfSectionTitle(
              'III. INFORMASI POSKO PENYERAHAN BARANG',
              navy,
              pale,
              border,
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(9),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: border),
              ),
              child: pw.Column(
                children: [
                  _pdfRow('Nama Posko / Instansi', _value(widget.namaPosko)),
                  _pdfRow('Alamat Lengkap', _value(widget.alamatPosko)),
                  _pdfRow(
                    'Wilayah / Kecamatan',
                    _value(
                      widget.wilayahPosko.isNotEmpty
                          ? widget.wilayahPosko
                          : widget.wilayah,
                    ),
                  ),
                  _pdfRow('Jam Layanan Operasional', _value(widget.jamLayanan)),
                  _pdfRow(
                    'Petugas Penanggung Jawab',
                    _value(widget.penanggungJawab),
                  ),
                  _pdfRow('Kontak Layanan', widget.kontak),
                  if (widget.catatanPosko.trim().isNotEmpty)
                    _pdfRow('Catatan Posko', widget.catatanPosko),
                ],
              ),
            ),
            pw.SizedBox(height: 9),
            _pdfSectionTitle(
              'IV. SYARAT PENYERAHAN FISIK BARANG',
              navy,
              pale,
              border,
            ),
            _pdfRequirement(
              '1',
              'Membawa Identitas Asli yang Sah',
              'Bawa KTM, KTP, atau SIM asli atas nama pemilik klaim.',
            ),
            _pdfRequirement(
              '2',
              'Menunjukkan Kode Tiket Klaim',
              'Tunjukkan kode $_kode kepada petugas loket posko.',
            ),
            _pdfRequirement(
              '3',
              'Pencocokan Ciri Khusus Bersama Petugas',
              'Petugas mencocokkan ciri khusus, detail fisik, nomor seri, atau isi barang.',
            ),
            _pdfRequirement(
              '4',
              'Konfirmasi & Penandatanganan Berita Acara',
              'Setelah barang terverifikasi, pemilik dan petugas menandatangani tanda terima.',
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Catatan Pengambilan',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: navy,
              ),
            ),
            pw.Text(
              'Wajib membawa kartu identitas asli dan menunjukkan bukti tiket ini saat pengambilan barang di posko layanan.',
              style: pw.TextStyle(fontSize: 8, color: slate),
            ),
            pw.SizedBox(height: 18),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: _pdfSignature(
                    'Penerima / Pemilik Barang',
                    _value(widget.namaPengambil),
                  ),
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: _pdfSignature(
                    'Petugas Penyerah Posko',
                    _value(widget.penanggungJawab),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Center(
              child: pw.Text(
                'Dokumen informasi klaim dari aplikasi SiNemu.',
                style: pw.TextStyle(fontSize: 7, color: slate),
              ),
            ),
          ],
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

  pw.Widget _pdfSectionTitle(
    String title,
    PdfColor textColor,
    PdfColor background,
    PdfColor border,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: pw.BoxDecoration(
        color: background,
        border: pw.Border.all(color: border),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 105,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 7.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 7.5)),
          pw.Expanded(
            child: pw.Text(
              _value(value),
              style: const pw.TextStyle(fontSize: 7.5),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfRequirement(String number, String title, String description) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 18,
            height: 18,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#E2E8F0'),
              border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
            ),
            child: pw.Text(
              number,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(width: 7),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(description, style: const pw.TextStyle(fontSize: 7.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfSignature(String role, String name) {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text(
            '$role,',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 8),
          ),
        ),
        pw.SizedBox(height: 42),
        pw.Container(
          width: double.infinity,
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.only(bottom: 3),
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black)),
          ),
          child: pw.Text(
            name,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Text(
          'Tanda tangan & nama terang',
          style: const pw.TextStyle(fontSize: 7),
        ),
      ],
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
              _value(value),
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
    debugPrint('FOTO BARANG: ${widget.fotoBarang}');

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
                          color: statusColor.withOpacity(.10),
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
                          _kode.startsWith('#') ? _kode : '#$_kode',
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
                  if (widget.fotoBarang.trim().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _normalizeImageUrl(widget.fotoBarang),
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
                    widget.namaBarang,
                  ),
                  _infoRow(
                    Icons.category_outlined,
                    'Kategori',
                    widget.kategoriBarang,
                  ),
                  _infoRow(
                    Icons.location_on_outlined,
                    'Lokasi Ditemukan',
                    widget.lokasiDitemukan,
                  ),
                  _infoRow(
                    Icons.event_outlined,
                    'Tanggal Temuan',
                    widget.tanggalTemuan,
                  ),
                  _infoRow(
                    Icons.notes_outlined,
                    'Deskripsi Fisik',
                    widget.deskripsiBarang,
                  ),
                  _infoRow(
                    Icons.fact_check_outlined,
                    'Ciri Khusus',
                    widget.ciriKhusus,
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
                    widget.namaPengambil,
                  ),
                  _infoRow(
                    Icons.phone_outlined,
                    'No. Telepon / WA',
                    widget.kontak,
                  ),
                  _infoRow(
                    Icons.email_outlined,
                    'Email Terdaftar',
                    widget.emailPengambil,
                  ),
                  _infoRow(
                    Icons.calendar_today_outlined,
                    'Tanggal Klaim',
                    widget.tanggal,
                  ),
                  _infoRow(
                    Icons.verified_outlined,
                    'Bukti Kepemilikan',
                    widget.buktiKepemilikan.isNotEmpty
                        ? widget.buktiKepemilikan
                        : widget.keterangan,
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
                    widget.namaPosko,
                  ),
                  _infoRow(
                    Icons.map_outlined,
                    'Alamat Lengkap',
                    widget.alamatPosko,
                  ),
                  _infoRow(
                    Icons.location_city_outlined,
                    'Wilayah / Kecamatan',
                    widget.wilayahPosko.isNotEmpty
                        ? widget.wilayahPosko
                        : widget.wilayah,
                  ),
                  _infoRow(
                    Icons.access_time_outlined,
                    'Jam Layanan Operasional',
                    widget.jamLayanan,
                  ),
                  _infoRow(
                    Icons.badge_outlined,
                    'Petugas Penanggung Jawab',
                    widget.penanggungJawab,
                  ),
                  if (widget.catatanPosko.trim().isNotEmpty)
                    _infoRow(
                      Icons.info_outline,
                      'Catatan Posko',
                      widget.catatanPosko,
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
              'Bawa KTM (Kartu Tanda Mahasiswa), KTP, atau SIM asli atas nama ${_value(widget.namaPengambil)} sesuai profil akun SiNemu.',
            ),
            _requirementCard(
              '2',
              'Menunjukkan Kode Tiket Klaim',
              'Tunjukkan kode tiket ${_kode.startsWith('#') ? _kode : '#$_kode'} pada layar smartphone Anda kepada petugas loket posko.',
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

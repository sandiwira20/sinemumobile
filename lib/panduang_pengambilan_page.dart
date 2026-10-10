import 'package:flutter/material.dart';

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
  });

  final String namaBarang;
  final String wilayah;
  final String nomorKlaim;
  final String statusKlaim;
  final String kontak;
  final String tanggal;
  final String keterangan;

  @override
  State<PanduanPengambilanPage> createState() => _PanduanPengambilanPageState();
}

class _PanduanPengambilanPageState extends State<PanduanPengambilanPage> {
  bool _isMembuatPdf = false;


  // Membuat dan membuka PDF bukti klaim.
  Future<void> _cetakBuktiKlaim() async {
    if (_isMembuatPdf) return;

    setState(() => _isMembuatPdf = true);

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (context) => [
            pw.Center(
              child: pw.Text(
                'SINEMU',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#357ABD'),
                ),
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Center(
              child: pw.Text(
                'BUKTI KLAIM DAN PANDUAN PENGAMBILAN',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 12),

            _pdfRow('Nomor Klaim', widget.nomorKlaim),
            _pdfRow('Nama Barang', widget.namaBarang),
            _pdfRow('Wilayah Pengambilan', widget.wilayah),
            _pdfRow('Status Klaim', widget.statusKlaim),
            _pdfRow('Tanggal Klaim', widget.tanggal),
            _pdfRow('Kontak', widget.kontak),
            _pdfRow(
              'Keterangan',
              widget.keterangan.trim().isEmpty ? '-' : widget.keterangan,
            ),

            pw.SizedBox(height: 18),
            pw.Divider(),
            pw.SizedBox(height: 12),

            pw.Text(
              'PANDUAN PENGAMBILAN BARANG',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),

            _pdfStep(
              '1',
              'Datang ke lokasi pengambilan',
              'Datang ke titik pengambilan di Kecamatan '
                  '${widget.wilayah}.',
            ),
            _pdfStep(
              '2',
              'Bawa kartu identitas',
              'Siapkan KTP atau identitas lain yang sesuai '
                  'dengan data pengajuan klaim.',
            ),
            _pdfStep(
              '3',
              'Tunjukkan bukti klaim',
              'Tunjukkan bukti klaim ini kepada petugas.',
            ),
            _pdfStep(
              '4',
              'Proses verifikasi',
              'Petugas memeriksa identitas dan mencocokkan '
                  'informasi barang.',
            ),
            _pdfStep(
              '5',
              'Ambil barang',
              'Setelah verifikasi selesai, barang dapat '
                  'diserahkan kepada pemilik.',
            ),

            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FFF3E0'),
                border: pw.Border.all(color: PdfColor.fromHex('#FFCC80')),
              ),
              child: pw.Text(
                'Penting: Bawa identitas asli dan bukti klaim '
                'saat mengambil barang. Pastikan status klaim '
                'telah disetujui.',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),

            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                'Dokumen ini merupakan bukti informasi klaim '
                'yang ditampilkan oleh aplikasi SINEMU.',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Bukti_Klaim_${widget.nomorKlaim}.pdf',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat PDF: $e')));
    } finally {
      if (mounted) {
        setState(() => _isMembuatPdf = false);
      }
    }
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 9),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 125,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
          ),
          pw.Text(': '),
          pw.Expanded(
            child: pw.Text(
              value.trim().isEmpty ? '-' : value,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfStep(String nomor, String judul, String deskripsi) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 22,
            height: 22,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#E8F1FC'),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Text(
              nomor,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#357ABD'),
                fontSize: 10,
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  judul,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(deskripsi, style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Panduan Pengambilan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header status klaim.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 42,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.statusKlaim.isEmpty
                        ? 'Panduan Pengambilan'
                        : 'Status: ${widget.statusKlaim}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Barang: ${widget.namaBarang}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nomor Klaim: ${widget.nomorKlaim}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Ringkasan informasi klaim.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _infoRow(
                    Icons.calendar_today_outlined,
                    'Tanggal Klaim',
                    widget.tanggal,
                  ),
                  const Divider(height: 22),
                  _infoRow(Icons.phone_outlined, 'Kontak', widget.kontak),
                  if (widget.keterangan.trim().isNotEmpty) ...[
                    const Divider(height: 22),
                    _infoRow(
                      Icons.notes_outlined,
                      'Keterangan',
                      widget.keterangan,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tombol PDF.
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
                      : 'Unduh / Cetak Bukti Klaim (PDF)',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Panduan Pengambilan Barang',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _buildStep(
              nomor: '1',
              icon: Icons.location_on_outlined,
              judul: 'Datang ke lokasi pengambilan',
              deskripsi:
                  'Silakan datang ke titik pengambilan di '
                  'Kecamatan ${widget.wilayah}.',
            ),

            const SizedBox(height: 4),

            _buildStep(
              nomor: '2',
              icon: Icons.badge_outlined,
              judul: 'Bawa kartu identitas',
              deskripsi:
                  'Siapkan KTP atau identitas lain yang sesuai '
                  'dengan data pada pengajuan klaim.',
            ),

            _buildStep(
              nomor: '3',
              icon: Icons.assignment_turned_in_outlined,
              judul: 'Tunjukkan bukti klaim',
              deskripsi:
                  'Tunjukkan halaman panduan ini atau PDF '
                  'bukti klaim kepada petugas.',
            ),

            _buildStep(
              nomor: '4',
              icon: Icons.verified_user_outlined,
              judul: 'Proses verifikasi',
              deskripsi:
                  'Petugas akan melakukan verifikasi identitas '
                  'dan mencocokkan informasi barang.',
            ),

            _buildStep(
              nomor: '5',
              icon: Icons.inventory_2_outlined,
              judul: 'Ambil barang',
              deskripsi:
                  'Setelah proses verifikasi selesai, barang '
                  'dapat diserahkan kepada pemilik.',
            ),

            const SizedBox(height: 4),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange.withOpacity(0.25)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pastikan membawa identitas asli dan '
                      'bukti klaim saat mengambil barang.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String judul, String nilai) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF4A90E2), size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                judul,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                nilai.trim().isEmpty ? '-' : nilai,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep({
    required String nomor,
    required IconData icon,
    required String judul,
    required String deskripsi,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              nomor,
              style: const TextStyle(
                color: Color(0xFF4A90E2),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 19, color: const Color(0xFF4A90E2)),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        judul,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  deskripsi,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

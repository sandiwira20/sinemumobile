import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'core/network/api_client.dart';
import 'features/laporan/services/laporan_service.dart';
import 'features/support_data/models/kategori_model.dart';
import 'features/support_data/models/wilayah_model.dart';
import 'features/support_data/services/support_data_service.dart';

class LaporPage extends StatefulWidget {
  const LaporPage({super.key});

  @override
  State<LaporPage> createState() => _LaporPageState();
}

class _LaporPageState extends State<LaporPage> {
  // Web: JPG, JPEG, PNG, WEBP — maks 3MB
  static const int _maxFotoBytes = 3 * 1024 * 1024;
  static const Set<String> _allowedFotoExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  final SupportDataService _supportDataService = SupportDataService();
  final LaporanService _laporanService = LaporanService();
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers — identik dengan web
  final TextEditingController _namaBarangController = TextEditingController();
  final TextEditingController _warnaDominanController = TextEditingController();
  final TextEditingController _merekController = TextEditingController();
  final TextEditingController _nomorSeriController = TextEditingController();
  final TextEditingController _lokasiController =
      TextEditingController(); // Lokasi Hilang (singkat)
  final TextEditingController _detailLokasiController =
      TextEditingController(); // Detail Lokasi Hilang
  final TextEditingController _deskripsiController =
      TextEditingController(); // Deskripsi Barang & Kronologi
  final TextEditingController _ciriUnikController =
      TextEditingController(); // Ciri Unik Barang
  final TextEditingController _noWaController =
      TextEditingController(); // No. WA — WAJIB
  final TextEditingController _buktiKepemilikanController =
      TextEditingController(); // Bukti Kepemilikan

  bool _isSupportDataLoading = true;
  bool _isSubmitting = false;
  String? _supportDataError;
  List<KategoriModel> _kategoris = [];
  List<WilayahModel> _wilayahs = [];
  String? _selectedKategoriId;
  String? _selectedWilayahId;
  DateTime? _selectedTanggal = DateTime.now();
  TimeOfDay? _selectedJam;
  XFile? _selectedFoto;

  @override
  void initState() {
    super.initState();
    _loadSupportData();
  }

  @override
  void dispose() {
    _namaBarangController.dispose();
    _warnaDominanController.dispose();
    _merekController.dispose();
    _nomorSeriController.dispose();
    _lokasiController.dispose();
    _detailLokasiController.dispose();
    _deskripsiController.dispose();
    _ciriUnikController.dispose();
    _noWaController.dispose();
    _buktiKepemilikanController.dispose();
    super.dispose();
  }

  // ─── Data Loading ───────────────────────────────────────────────────────────

  Future<void> _loadSupportData() async {
    setState(() {
      _isSupportDataLoading = true;
      _supportDataError = null;
    });
    try {
      final supportData = await _supportDataService.getSupportData();
      if (!mounted) return;
      setState(() {
        _kategoris = supportData.kategoris;
        _wilayahs = supportData.wilayahs;
        _selectedKategoriId = null;
        _selectedWilayahId = null;
        _isSupportDataLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _supportDataError = error.statusCode == 401
            ? 'Sesi login sudah berakhir. Silakan login ulang.'
            : error.message;
        _isSupportDataLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _supportDataError = 'Gagal memuat kategori dan wilayah.';
        _isSupportDataLoading = false;
      });
    }
  }

  // ─── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _submitLaporan() async {
    final validationMessage = _validateForm();
    if (validationMessage != null) {
      _showSnackBar(validationMessage, isError: true);
      return;
    }

    final request = LaporanRequest(
      jenis: JenisLaporan.hilang,
      namaBarang: _namaBarangController.text.trim(),
      kategoriId: _selectedKategoriId!,
      wilayahId: _selectedWilayahId!,
      lokasi: _lokasiController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      tanggal: _selectedTanggal!,
      warnaDominan: _nullIfEmpty(_warnaDominanController.text),
      merek: _nullIfEmpty(_merekController.text),
      nomorSeri: _nullIfEmpty(_nomorSeriController.text),
      perkiraanJam: _selectedJam,
      detailLokasi: _nullIfEmpty(_detailLokasiController.text),
      ciriUnik: _nullIfEmpty(_ciriUnikController.text),
      noWa: _noWaController.text.trim(),
      buktiKepemilikan: _nullIfEmpty(_buktiKepemilikanController.text),
    );

    setState(() => _isSubmitting = true);
    try {
      await _laporanService.submitLaporan(
        request,
        fotoPath: _selectedFoto?.path,
      );
      if (!mounted) return;
      _clearForm();
      _showSnackBar('Laporan berhasil dikirim!');
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnackBar(_apiErrorMessage(error), isError: true);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(
        'Laporan gagal dikirim. Coba lagi beberapa saat.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ─── Validation ──────────────────────────────────────────────────────────────

  String? _validateForm() {
    if (_namaBarangController.text.trim().isEmpty)
      return 'Nama barang wajib diisi.';
    if (_selectedWilayahId == null) return 'Wilayah kejadian wajib dipilih.';
    if (_lokasiController.text.trim().isEmpty)
      return 'Lokasi hilang wajib diisi.';
    if (_selectedTanggal == null) return 'Tanggal hilang wajib dipilih.';
    if (_deskripsiController.text.trim().isEmpty)
      return 'Deskripsi barang dan kronologi wajib diisi.';
    if (_noWaController.text.trim().isEmpty)
      return 'No. WA yang bisa dihubungi wajib diisi.';
    return null;
  }

  void _clearForm() {
    for (final c in [
      _namaBarangController,
      _warnaDominanController,
      _merekController,
      _nomorSeriController,
      _lokasiController,
      _detailLokasiController,
      _deskripsiController,
      _ciriUnikController,
      _noWaController,
      _buktiKepemilikanController,
    ]) {
      c.clear();
    }
    setState(() {
      _selectedKategoriId = null;
      _selectedWilayahId = null;
      _selectedTanggal = DateTime.now();
      _selectedJam = null;
      _selectedFoto = null;
    });
  }

  // ─── Pickers ────────────────────────────────────────────────────────────────

  Future<void> _pickTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedTanggal ?? now,
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedTanggal = picked);
  }

  Future<void> _pickJam() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedJam ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedJam = picked);
  }

  Future<void> _pickFoto() async {
    try {
      final pickedFoto = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFoto == null) return;
      final msg = await _validateFoto(pickedFoto);
      if (msg != null) {
        _showSnackBar(msg, isError: true);
        return;
      }
      setState(() => _selectedFoto = pickedFoto);
    } catch (_) {
      _showSnackBar('Gagal memilih foto dari galeri.', isError: true);
    }
  }

  Future<String?> _validateFoto(XFile foto) async {
    final ext = _fotoExtension(foto);
    if (!_allowedFotoExtensions.contains(ext)) {
      return 'Format foto harus JPG, JPEG, PNG, atau WEBP.';
    }
    final size = await foto.length();
    if (size > _maxFotoBytes) return 'Ukuran foto maksimal 3 MB.';
    return null;
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String? _nullIfEmpty(String value) =>
      value.trim().isEmpty ? null : value.trim();

  String _fotoExtension(XFile foto) {
    final src = foto.name.isNotEmpty ? foto.name : foto.path;
    final parts = src.split('.');
    return parts.length < 2 ? '' : parts.last.toLowerCase();
  }

  String _fotoName(XFile foto) {
    if (foto.name.isNotEmpty) return foto.name;
    return foto.path.split(Platform.pathSeparator).last;
  }

  String _formatDate(DateTime v) {
    return '${v.year}-${v.month.toString().padLeft(2, '0')}-${v.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay v) {
    return '${v.hour.toString().padLeft(2, '0')}:${v.minute.toString().padLeft(2, '0')}';
  }

  String _apiErrorMessage(ApiException error) => switch (error.statusCode) {
    401 => 'Sesi login sudah berakhir. Silakan login ulang.',
    413 => 'Ukuran foto terlalu besar.',
    _ => error.message,
  };

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Lapor Barang Hilang',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info hint
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Isi data secara lengkap agar tim SiNemu lebih cepat membantu proses pencarian.',
                style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),

            // ── 1. Nama Barang ───────────────────────────────────────────────
            _buildLabel('Nama Barang', required: true),
            const SizedBox(height: 8),
            _buildTextField(
              'Contoh: Dompet Coklat',
              controller: _namaBarangController,
            ),
            const SizedBox(height: 20),

            // ── 2. Wilayah Kejadian ──────────────────────────────────────────
            _buildLabel('Wilayah Kejadian', required: true),
            const SizedBox(height: 8),
            _buildSupportDataWilayah(),
            const SizedBox(height: 6),
            Text(
              'Laporan akan masuk ke pengelola barang wilayah yang dipilih.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // ── 3. Kategori Barang ───────────────────────────────────────────
            _buildLabel('Kategori Barang'),
            const SizedBox(height: 8),
            _buildSupportDataKategori(),
            const SizedBox(height: 20),

            // ── 4. Warna Dominan ─────────────────────────────────────────────
            _buildLabel('Warna Dominan'),
            const SizedBox(height: 8),
            _buildTextField(
              'Contoh: Hitam',
              controller: _warnaDominanController,
            ),
            const SizedBox(height: 20),

            // ── 5. Merek / Brand ─────────────────────────────────────────────
            _buildLabel('Merek / Brand'),
            const SizedBox(height: 8),
            _buildTextField(
              'Contoh: Samsung, Eiger, Casio',
              controller: _merekController,
            ),
            const SizedBox(height: 20),

            // ── 6. Nomor Seri / Kode Unik ────────────────────────────────────
            _buildLabel('Nomor Seri / Kode Unik'),
            const SizedBox(height: 8),
            _buildTextField(
              'Contoh: IMEI, nomor seri, kode produksi',
              controller: _nomorSeriController,
            ),
            const SizedBox(height: 20),

            // ── 7. Lokasi Hilang ─────────────────────────────────────────────
            _buildLabel('Lokasi Hilang', required: true),
            const SizedBox(height: 8),
            _buildTextField(
              'Contoh: Area parkir timur',
              controller: _lokasiController,
            ),
            const SizedBox(height: 20),

            // ── 8. Tanggal Hilang ────────────────────────────────────────────
            _buildLabel('Tanggal Hilang', required: true),
            const SizedBox(height: 8),
            _buildDateField(),
            const SizedBox(height: 20),

            // ── 9. Perkiraan Jam Hilang ──────────────────────────────────────
            _buildLabel('Perkiraan Jam Hilang'),
            const SizedBox(height: 8),
            _buildTimeField(),
            const SizedBox(height: 20),

            // ── 10. Detail Lokasi Hilang ─────────────────────────────────────
            _buildLabel('Detail Lokasi Hilang'),
            const SizedBox(height: 8),
            _buildTextField(
              'Contoh: Dekat ATM sisi kiri, sekitar 10 meter dari pintu utama.',
              controller: _detailLokasiController,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // ── 11. Deskripsi Barang dan Kronologi Singkat ───────────────────
            _buildLabel(
              'Deskripsi Barang dan Kronologi Singkat',
              required: true,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              'Jelaskan barang, kapan terakhir terlihat, dan kronologi singkat kejadian.',
              controller: _deskripsiController,
              maxLines: 4,
            ),
            const SizedBox(height: 6),
            Text(
              'Data yang lebih rinci akan memudahkan proses validasi.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // ── 12. Ciri Unik Barang ─────────────────────────────────────────
            _buildLabel('Ciri Unik Barang'),
            const SizedBox(height: 8),
            _buildTextField(
              'Contoh: Ada stiker kampus di sisi belakang, resleting kiri agak seret.',
              controller: _ciriUnikController,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // ── 13. No. WA yang Bisa Dihubungi ──────────────────────────────
            _buildLabel('No. WA yang Bisa Dihubungi', required: true),
            const SizedBox(height: 8),
            _buildTextField(
              'Contoh: 081234567890',
              controller: _noWaController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // ── 14. Bukti Kepemilikan ────────────────────────────────────────
            _buildLabel('Bukti Kepemilikan (Opsional)'),
            const SizedBox(height: 8),
            _buildTextField(
              'Contoh: Ada foto saat barang dipakai, nomor seri, atau detail isi barang yang hanya pemilik tahu.',
              controller: _buktiKepemilikanController,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // ── 15. Foto Barang ──────────────────────────────────────────────
            _buildLabel('Foto Barang (Opsional)'),
            const SizedBox(height: 8),
            _buildFotoPicker(),
            const SizedBox(height: 40),

            // ── Tombol Kirim ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitLaporan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'KIRIM LAPORAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─── Section Widgets ─────────────────────────────────────────────────────────

  /// Wilayah saja (terpisah agar bisa ditempatkan sendiri)
  Widget _buildSupportDataWilayah() {
    if (_isSupportDataLoading) return _buildSupportDataLoading();
    if (_supportDataError != null) return _buildSupportDataError();
    return _buildWilayahDropdown();
  }

  /// Kategori saja
  Widget _buildSupportDataKategori() {
    if (_isSupportDataLoading) return _buildSupportDataLoading();
    if (_supportDataError != null) return const SizedBox.shrink();
    return _buildKategoriDropdown();
  }

  // ─── Field Widgets ───────────────────────────────────────────────────────────

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(
    String hint, {
    TextEditingController? controller,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: !_isSubmitting,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildKategoriDropdown() {
    if (_kategoris.isEmpty)
      return _buildEmptySupportDataField('Belum ada kategori dari server');
    return DropdownButtonFormField<String>(
      key: ValueKey('kategori-${_selectedKategoriId ?? 'empty'}'),
      initialValue: _selectedKategoriId,
      decoration: _fieldDecoration(),
      hint: Text(
        'Pilih kategori',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),
      items: _kategoris
          .map((k) => DropdownMenuItem(value: k.id, child: Text(k.nama)))
          .toList(),
      onChanged: _isSubmitting
          ? null
          : (v) => setState(() => _selectedKategoriId = v),
    );
  }

  Widget _buildWilayahDropdown() {
    if (_wilayahs.isEmpty)
      return _buildEmptySupportDataField('Belum ada wilayah dari server');
    return DropdownButtonFormField<String>(
      key: ValueKey('wilayah-${_selectedWilayahId ?? 'empty'}'),
      initialValue: _selectedWilayahId,
      decoration: _fieldDecoration(),
      hint: Text(
        'Pilih kecamatan',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),
      items: _wilayahs
          .map((w) => DropdownMenuItem(value: w.id, child: Text(w.nama)))
          .toList(),
      onChanged: _isSubmitting
          ? null
          : (v) => setState(() => _selectedWilayahId = v),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _isSubmitting ? null : _pickTanggal,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 10),
            Text(
              _selectedTanggal == null
                  ? 'dd/mm/tttt'
                  : _formatDate(_selectedTanggal!),
              style: TextStyle(
                color: _selectedTanggal == null
                    ? Colors.grey.shade400
                    : Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return InkWell(
      onTap: _isSubmitting ? null : _pickJam,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_outlined,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 10),
            Text(
              _selectedJam == null ? '-- : --' : _formatTime(_selectedJam!),
              style: TextStyle(
                color: _selectedJam == null
                    ? Colors.grey.shade400
                    : Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoPicker() {
    return InkWell(
      onTap: _isSubmitting ? null : _pickFoto,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: _selectedFoto == null
            ? _buildFotoPlaceholder()
            : _buildFotoPreview(_selectedFoto!),
      ),
    );
  }

  Widget _buildFotoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey.shade400),
        const SizedBox(height: 10),
        Text(
          'Ketuk untuk tambah foto',
          style: TextStyle(color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        Text(
          'JPG, JPEG, PNG, WEBP maks. 3 MB',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFotoPreview(XFile foto) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(foto.path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _isSubmitting
                ? null
                : () => setState(() => _selectedFoto = null),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Text(
              _fotoName(foto),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportDataLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Memuat data...',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportDataError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _supportDataError!,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadSupportData,
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySupportDataField(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      ),
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

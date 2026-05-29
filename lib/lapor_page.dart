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
  static const int _maxFotoBytes = 2 * 1024 * 1024;
  static const Set<String> _allowedFotoExtensions = {'jpg', 'jpeg', 'png'};

  final SupportDataService _supportDataService = SupportDataService();
  final LaporanService _laporanService = LaporanService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _namaBarangController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  bool _isSupportDataLoading = true;
  bool _isSubmitting = false;
  String? _supportDataError;
  List<KategoriModel> _kategoris = [];
  List<WilayahModel> _wilayahs = [];
  String? _selectedJenisLaporan;
  String? _selectedKategoriId;
  String? _selectedWilayahId;
  DateTime? _selectedTanggal = DateTime.now();
  XFile? _selectedFoto;

  @override
  void initState() {
    super.initState();
    _loadSupportData();
  }

  @override
  void dispose() {
    _namaBarangController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

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

  Future<void> _submitLaporan() async {
    final validationMessage = _validateForm();
    if (validationMessage != null) {
      _showSnackBar(validationMessage, isError: true);
      return;
    }

    final jenis = _jenisLaporanFromSelection(_selectedJenisLaporan!);
    final request = LaporanRequest(
      jenis: jenis,
      namaBarang: _namaBarangController.text.trim(),
      kategoriId: _selectedKategoriId!,
      wilayahId: _selectedWilayahId!,
      lokasi: _lokasiController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      tanggal: _selectedTanggal!,
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
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String? _validateForm() {
    if (_selectedJenisLaporan == null) {
      return 'Jenis laporan wajib dipilih.';
    }

    if (_namaBarangController.text.trim().isEmpty) {
      return 'Nama barang wajib diisi.';
    }

    if (_selectedKategoriId == null) {
      return 'Kategori wajib dipilih.';
    }

    if (_selectedWilayahId == null) {
      return 'Wilayah wajib dipilih.';
    }

    if (_lokasiController.text.trim().isEmpty) {
      return 'Lokasi wajib diisi.';
    }

    if (_deskripsiController.text.trim().isEmpty) {
      return 'Deskripsi wajib diisi.';
    }

    if (_selectedTanggal == null) {
      return _selectedJenisLaporan == 'Barang Temuan'
          ? 'Tanggal ditemukan wajib dipilih.'
          : 'Tanggal hilang wajib dipilih.';
    }

    return null;
  }

  JenisLaporan _jenisLaporanFromSelection(String value) {
    return value == 'Barang Hilang' ? JenisLaporan.hilang : JenisLaporan.temuan;
  }

  void _clearForm() {
    _namaBarangController.clear();
    _lokasiController.clear();
    _deskripsiController.clear();
    setState(() {
      _selectedJenisLaporan = null;
      _selectedKategoriId = null;
      _selectedWilayahId = null;
      _selectedTanggal = DateTime.now();
      _selectedFoto = null;
    });
  }

  Future<void> _pickTanggalLaporan() async {
    final now = DateTime.now();
    final currentDate = _selectedTanggal ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedTanggal = picked);
    }
  }

  String _tanggalLaporanLabel() {
    return _selectedJenisLaporan == 'Barang Temuan'
        ? 'Tanggal Ditemukan'
        : 'Tanggal Hilang';
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  Future<void> _pickFoto() async {
    try {
      final pickedFoto = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFoto == null) {
        return;
      }

      final validationMessage = await _validateFoto(pickedFoto);
      if (validationMessage != null) {
        _showSnackBar(validationMessage, isError: true);
        return;
      }

      setState(() => _selectedFoto = pickedFoto);
    } catch (_) {
      _showSnackBar('Gagal memilih foto dari galeri.', isError: true);
    }
  }

  Future<String?> _validateFoto(XFile foto) async {
    final extension = _fotoExtension(foto);
    if (!_allowedFotoExtensions.contains(extension)) {
      return 'Format foto harus JPG, JPEG, atau PNG.';
    }

    final size = await foto.length();
    if (size > _maxFotoBytes) {
      return 'Ukuran foto maksimal 2 MB.';
    }

    return null;
  }

  String _fotoExtension(XFile foto) {
    final source = foto.name.isNotEmpty ? foto.name : foto.path;
    final parts = source.split('.');
    if (parts.length < 2) {
      return '';
    }

    return parts.last.toLowerCase();
  }

  String _fotoName(XFile foto) {
    if (foto.name.isNotEmpty) {
      return foto.name;
    }

    return foto.path.split(Platform.pathSeparator).last;
  }

  String _apiErrorMessage(ApiException error) {
    return switch (error.statusCode) {
      401 => 'Sesi login sudah berakhir. Silakan login ulang.',
      413 => 'Ukuran foto terlalu besar.',
      _ => error.message,
    };
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Buat Laporan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- JENIS LAPORAN ---
            const Text(
              'Jenis Laporan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildDropdown(
              ['Barang Hilang', 'Barang Temuan'],
              'Pilih jenis laporan',
              value: _selectedJenisLaporan,
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      setState(() => _selectedJenisLaporan = value);
                    },
            ),
            const SizedBox(height: 25),

            // --- NAMA BARANG ---
            const Text(
              'Nama Barang',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              'Contoh: Dompet Hitam, Kunci Motor...',
              controller: _namaBarangController,
            ),
            const SizedBox(height: 25),

            _buildSupportDataSection(),
            const SizedBox(height: 25),

            // --- LOKASI ---
            const Text(
              'Lokasi Kejadian',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              'Lokasi terakhir dilihat / ditemukan...',
              controller: _lokasiController,
            ),
            const SizedBox(height: 25),

            Text(
              _tanggalLaporanLabel(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildDateField(),
            const SizedBox(height: 25),

            // --- DESKRIPSI ---
            const Text(
              'Deskripsi Tambahan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              'Sebutkan ciri-ciri khusus (warna, merk, isi dompet, dll)...',
              controller: _deskripsiController,
              maxLines: 4,
            ),
            const SizedBox(height: 25),

            // --- UPLOAD FOTO ---
            const Text(
              'Foto Barang (Jika Ada)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildFotoPicker(),
            const SizedBox(height: 40),

            // --- TOMBOL KIRIM ---
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

  Widget _buildSupportDataSection() {
    if (_isSupportDataLoading) {
      return _buildSupportDataLoading();
    }

    if (_supportDataError != null) {
      return _buildSupportDataError();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        _buildKategoriDropdown(),
        const SizedBox(height: 25),
        const Text(
          'Wilayah',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        _buildWilayahDropdown(),
      ],
    );
  }

  Widget _buildFotoPicker() {
    final selectedFoto = _selectedFoto;

    return InkWell(
      onTap: _isSubmitting ? null : _pickFoto,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: selectedFoto == null
            ? _buildFotoPlaceholder()
            : _buildFotoPreview(selectedFoto),
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
          'JPG, JPEG, PNG maks. 2 MB',
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
            borderRadius: BorderRadius.circular(15),
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
                bottom: Radius.circular(15),
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

  Widget _buildKategoriDropdown() {
    if (_kategoris.isEmpty) {
      return _buildEmptySupportDataField('Belum ada kategori dari server');
    }

    return DropdownButtonFormField<String>(
      key: ValueKey('kategori-${_selectedKategoriId ?? 'empty'}'),
      initialValue: _selectedKategoriId,
      decoration: _fieldDecoration(),
      hint: Text(
        'Pilih kategori barang',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),
      items: _kategoris.map((kategori) {
        return DropdownMenuItem<String>(
          value: kategori.id,
          child: Text(kategori.nama),
        );
      }).toList(),
      onChanged: _isSubmitting
          ? null
          : (value) {
              setState(() => _selectedKategoriId = value);
            },
    );
  }

  Widget _buildWilayahDropdown() {
    if (_wilayahs.isEmpty) {
      return _buildEmptySupportDataField('Belum ada wilayah dari server');
    }

    return DropdownButtonFormField<String>(
      key: ValueKey('wilayah-${_selectedWilayahId ?? 'empty'}'),
      initialValue: _selectedWilayahId,
      decoration: _fieldDecoration(),
      hint: Text(
        'Pilih wilayah kejadian',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),
      items: _wilayahs.map((wilayah) {
        return DropdownMenuItem<String>(
          value: wilayah.id,
          child: Text(wilayah.nama),
        );
      }).toList(),
      onChanged: _isSubmitting
          ? null
          : (value) {
              setState(() => _selectedWilayahId = value);
            },
    );
  }

  Widget _buildDateField() {
    final selectedTanggal = _selectedTanggal;

    return InkWell(
      onTap: _isSubmitting ? null : _pickTanggalLaporan,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 10),
            Text(
              selectedTanggal == null
                  ? 'Pilih tanggal'
                  : _formatDate(selectedTanggal),
              style: TextStyle(
                color: selectedTanggal == null
                    ? Colors.grey.shade400
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportDataLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
            'Memuat kategori dan wilayah...',
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
        borderRadius: BorderRadius.circular(15),
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
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      ),
    );
  }

  // WIDGET BANTUAN: Untuk Form Input Teks
  Widget _buildTextField(
    String hint, {
    TextEditingController? controller,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: !_isSubmitting,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // WIDGET BANTUAN: Untuk Form Dropdown (Pilihan)
  Widget _buildDropdown(
    List<String> items,
    String hint, {
    String? value,
    ValueChanged<String?>? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      key: ValueKey('dropdown-$hint-${value ?? 'empty'}'),
      initialValue: value,
      decoration: _fieldDecoration(),
      hint: Text(
        hint,
        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: _isSubmitting ? null : onChanged,
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}

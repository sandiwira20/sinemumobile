import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'core/network/api_client.dart';
import 'features/laporan/models/laporan_model.dart';
import 'features/laporan/services/laporan_service.dart';
import 'features/support_data/models/kategori_model.dart';
import 'features/support_data/models/wilayah_model.dart';
import 'features/support_data/services/support_data_service.dart';

class EditLaporanHilangPage extends StatefulWidget {
  const EditLaporanHilangPage({super.key, required this.laporan});

  final LaporanModel laporan;

  @override
  State<EditLaporanHilangPage> createState() => _EditLaporanHilangPageState();
}

class _EditLaporanHilangPageState extends State<EditLaporanHilangPage> {
  static const int _maxFotoBytes = 2 * 1024 * 1024;
  static const Set<String> _allowedFotoExtensions = {'jpg', 'jpeg', 'png'};

  final SupportDataService _supportDataService = SupportDataService();
  final LaporanService _laporanService = LaporanService();
  final ImagePicker _imagePicker = ImagePicker();
  late final TextEditingController _namaBarangController;
  late final TextEditingController _lokasiController;
  late final TextEditingController _deskripsiController;

  bool _isSupportDataLoading = true;
  bool _isSaving = false;
  String? _supportDataError;
  List<KategoriModel> _kategoris = [];
  List<WilayahModel> _wilayahs = [];
  String? _selectedKategoriId;
  String? _selectedWilayahId;
  XFile? _selectedFoto;
  late DateTime _tanggalHilang;

  @override
  void initState() {
    super.initState();
    _namaBarangController = TextEditingController(
      text: widget.laporan.namaBarang,
    );
    _lokasiController = TextEditingController(text: widget.laporan.lokasi);
    _deskripsiController = TextEditingController(
      text: widget.laporan.deskripsi,
    );
    _tanggalHilang = _parseDate(widget.laporan.tanggal) ?? DateTime.now();
    _selectedKategoriId = _emptyToNull(widget.laporan.kategoriId);
    _selectedWilayahId = _emptyToNull(widget.laporan.wilayahId);
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
        _selectedKategoriId = _resolveKategoriId();
        _selectedWilayahId = _resolveWilayahId();
        _isSupportDataLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _supportDataError = _apiErrorMessage(error);
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

  Future<void> _submitUpdate() async {
    final validationMessage = _validateForm();
    if (validationMessage != null) {
      _showSnackBar(validationMessage, isError: true);
      return;
    }

    final reportId = widget.laporan.numericId;
    if (reportId == null) {
      _showSnackBar('ID laporan tidak valid.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _laporanService.updateLaporanHilang(
        id: reportId,
        request: LaporanHilangUpdateRequest(
          namaBarang: _namaBarangController.text.trim(),
          kategoriId: _selectedKategoriId!,
          wilayahId: _selectedWilayahId!,
          lokasi: _lokasiController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          tanggalHilang: _tanggalHilang,
        ),
        fotoPath: _selectedFoto?.path,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnackBar(_apiErrorMessage(error), isError: true);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Laporan gagal diperbarui. Coba lagi.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _validateForm() {
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

    return null;
  }

  String _apiErrorMessage(ApiException error) {
    return switch (error.statusCode) {
      401 => 'Sesi login sudah berakhir. Silakan login ulang.',
      403 => 'Tidak punya akses untuk mengubah laporan ini.',
      404 => 'Laporan tidak ditemukan.',
      413 => 'Ukuran foto terlalu besar.',
      _ => error.message,
    };
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

  String? _resolveKategoriId() {
    final selectedId = _emptyToNull(_selectedKategoriId);
    if (selectedId != null &&
        _kategoris.any((kategori) => kategori.id == selectedId)) {
      return selectedId;
    }

    final laporanKategori = _normalizeText(widget.laporan.kategori);
    for (final kategori in _kategoris) {
      if (_normalizeText(kategori.nama) == laporanKategori) {
        return kategori.id;
      }
    }

    return null;
  }

  String? _resolveWilayahId() {
    final selectedId = _emptyToNull(_selectedWilayahId);
    if (selectedId != null &&
        _wilayahs.any((wilayah) => wilayah.id == selectedId)) {
      return selectedId;
    }

    final laporanWilayah = _normalizeText(widget.laporan.wilayah);
    for (final wilayah in _wilayahs) {
      if (_normalizeText(wilayah.nama) == laporanWilayah) {
        return wilayah.id;
      }
    }

    return null;
  }

  DateTime? _parseDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == '-') {
      return null;
    }

    final datePart = trimmed.length >= 10 ? trimmed.substring(0, 10) : trimmed;
    return DateTime.tryParse(datePart);
  }

  Future<void> _pickTanggalHilang() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalHilang,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _tanggalHilang = picked);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty || trimmed == '-') {
      return null;
    }

    return trimmed;
  }

  String _normalizeText(String value) {
    return value.trim().toLowerCase();
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
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
          'Edit Laporan Hilang',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSupportDataLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_supportDataError != null) {
      return _buildSupportDataError();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Nama Barang'),
          _buildTextField(
            'Contoh: Dompet hitam',
            controller: _namaBarangController,
          ),
          const SizedBox(height: 20),
          _buildLabel('Kategori'),
          _buildKategoriDropdown(),
          const SizedBox(height: 20),
          _buildLabel('Wilayah'),
          _buildWilayahDropdown(),
          const SizedBox(height: 20),
          _buildLabel('Lokasi Kejadian'),
          _buildTextField(
            'Lokasi terakhir dilihat',
            controller: _lokasiController,
          ),
          const SizedBox(height: 20),
          _buildLabel('Tanggal Hilang'),
          _buildDateField(),
          const SizedBox(height: 20),
          _buildLabel('Deskripsi Tambahan'),
          _buildTextField(
            'Sebutkan ciri-ciri khusus',
            controller: _deskripsiController,
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          _buildLabel('Foto Barang (Opsional)'),
          _buildFotoPicker(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submitUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'SIMPAN PERUBAHAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportDataError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 42),
            const SizedBox(height: 12),
            Text(
              _supportDataError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadSupportData,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: !_isSaving,
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

  Widget _buildFotoPicker() {
    final selectedFoto = _selectedFoto;

    return InkWell(
      onTap: _isSaving ? null : _pickFoto,
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
    final hasExistingFoto = widget.laporan.imageUrl.trim().isNotEmpty;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          hasExistingFoto ? Icons.image_outlined : Icons.add_a_photo_outlined,
          size: 40,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 10),
        Text(
          hasExistingFoto
              ? 'Foto lama tersedia. Ketuk untuk mengganti'
              : 'Ketuk untuk tambah foto',
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
            onTap: _isSaving
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
      return _buildEmptyDropdown('Belum ada kategori dari server');
    }

    return DropdownButtonFormField<String>(
      key: ValueKey('edit-kategori-${_selectedKategoriId ?? 'empty'}'),
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
      onChanged: _isSaving
          ? null
          : (value) {
              setState(() => _selectedKategoriId = value);
            },
    );
  }

  Widget _buildWilayahDropdown() {
    if (_wilayahs.isEmpty) {
      return _buildEmptyDropdown('Belum ada wilayah dari server');
    }

    return DropdownButtonFormField<String>(
      key: ValueKey('edit-wilayah-${_selectedWilayahId ?? 'empty'}'),
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
      onChanged: _isSaving
          ? null
          : (value) {
              setState(() => _selectedWilayahId = value);
            },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _isSaving ? null : _pickTanggalHilang,
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
            Text(_formatDate(_tanggalHilang)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDropdown(String message) {
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

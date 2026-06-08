import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'core/network/api_client.dart';
import 'features/klaim/services/klaim_service.dart';
import 'features/laporan/models/laporan_model.dart';

class AjukanKlaimPage extends StatefulWidget {
  final LaporanModel laporan;

  const AjukanKlaimPage({super.key, required this.laporan});

  @override
  State<AjukanKlaimPage> createState() => _AjukanKlaimPageState();
}

class _AjukanKlaimPageState extends State<AjukanKlaimPage> {
  final _klaimService = KlaimService();
  final _formKey = GlobalKey<FormState>();

  final _kontakController = TextEditingController();
  final _buktiKepemilikanController = TextEditingController();
  final _ciriKhususController = TextEditingController();
  final _detailIsiController = TextEditingController();
  final _lokasiSpesifikController = TextEditingController();
  final _waktuHilangController = TextEditingController();
  final _catatanController = TextEditingController();

  final List<File> _selectedPhotos = [];
  bool _persetujuan = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _kontakController.dispose();
    _buktiKepemilikanController.dispose();
    _ciriKhususController.dispose();
    _detailIsiController.dispose();
    _lokasiSpesifikController.dispose();
    _waktuHilangController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    if (_selectedPhotos.length >= 3) {
      _showSnackBar('Maksimal 3 foto.', isError: true);
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);

    if (picked.isEmpty) return;

    final remaining = 3 - _selectedPhotos.length;
    final toAdd = picked.take(remaining).map((x) => File(x.path)).toList();

    setState(() => _selectedPhotos.addAll(toAdd));
  }

  void _removePhoto(int index) {
    setState(() => _selectedPhotos.removeAt(index));
  }

  Future<void> _pickWaktu() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hh = picked.hour.toString().padLeft(2, '0');
      final mm = picked.minute.toString().padLeft(2, '0');
      _waktuHilangController.text = '$hh:$mm';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPhotos.isEmpty) {
      _showSnackBar('Minimal 1 foto bukti kepemilikan.', isError: true);
      return;
    }

    if (!_persetujuan) {
      _showSnackBar('Centang persetujuan terlebih dahulu.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _klaimService.submitKlaimBarangTemuan(
        barangId: widget.laporan.numericId!,
        kontakPelapor: _kontakController.text.trim(),
        buktiKepemilikan: _buktiKepemilikanController.text.trim(),
        buktiCiriKhusus: _ciriKhususController.text.trim(),
        buktiLokasiSpesifik: _lokasiSpesifikController.text.trim(),
        buktiWaktuHilang: _waktuHilangController.text.trim(),
        buktiFoto: _selectedPhotos,
        buktiDetailIsi: _detailIsiController.text.trim(),
        catatan: _catatanController.text.trim(),
      );

      if (!mounted) return;
      _showSnackBar('Klaim berhasil diajukan!');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnackBar(
        e.statusCode == 409
            ? 'Klaim sudah pernah diajukan untuk barang ini.'
            : e.message,
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Gagal mengajukan klaim. Coba lagi.', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Ajukan Klaim',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info barang
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BARANG YANG DIKLAIM',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.laporan.namaBarang,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.laporan.kategori} • ${widget.laporan.lokasi}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('No. WA yang Bisa Dihubungi', required: true),
              _buildTextField(
                controller: _kontakController,
                hint: 'Contoh: 08123456789',
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Bukti Kepemilikan', required: true),
              _buildTextField(
                controller: _buktiKepemilikanController,
                hint:
                    'Tuliskan bukti yang hanya pemilik asli tahu: isi barang, foto saat dipakai, nomor seri, nota, dll.',
                maxLines: 4,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Ciri Unik Barang', required: true),
              _buildTextField(
                controller: _ciriKhususController,
                hint:
                    'Contoh: ada stiker, goresan, ukiran nama, aksesoris khusus.',
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Detail Isi / Kondisi Saat Hilang'),
              _buildTextField(
                controller: _detailIsiController,
                hint:
                    'Contoh: isi tas, casing, wallpaper, atau detail kondisi terakhir.',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              _buildLabel('Lokasi Spesifik Hilang', required: true),
              _buildTextField(
                controller: _lokasiSpesifikController,
                hint: 'Contoh: meja pojok kanan perpustakaan',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Perkiraan Waktu Hilang', required: true),
              GestureDetector(
                onTap: _pickWaktu,
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _waktuHilangController,
                    hint: 'Pilih waktu (HH:MM)',
                    suffixIcon: const Icon(Icons.access_time),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                      final regex = RegExp(r'^([01]?\d|2[0-3]):[0-5]\d$');
                      if (!regex.hasMatch(v.trim()))
                        return 'Format waktu tidak valid (HH:MM)';
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Foto Bukti Kepemilikan', required: true),
              const Text(
                'Unggah 1-3 foto (JPG, PNG, WEBP), maks 2MB per file.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _buildPhotoSection(),
              const SizedBox(height: 16),

              _buildLabel('Catatan Tambahan'),
              _buildTextField(
                controller: _catatanController,
                hint: 'Tambahkan keterangan pendukung jika diperlukan.',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Persetujuan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _persetujuan,
                    onChanged: (v) => setState(() => _persetujuan = v ?? false),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Saya menyatakan data klaim ini benar dan siap diverifikasi oleh pengelola barang.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tombol submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Ajukan Klaim',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A90E2)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ..._selectedPhotos.asMap().entries.map((entry) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  entry.value,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removePhoto(entry.key),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        if (_selectedPhotos.length < 3)
          GestureDetector(
            onTap: _pickPhotos,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Colors.grey,
                    size: 28,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tambah Foto',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

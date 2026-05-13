import 'package:flutter/material.dart';

class LaporPage extends StatelessWidget {
  const LaporPage({super.key});

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
            _buildDropdown([
              'Barang Hilang',
              'Barang Temuan',
            ], 'Pilih jenis laporan'),
            const SizedBox(height: 25),

            // --- NAMA BARANG ---
            const Text(
              'Nama Barang',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildTextField('Contoh: Dompet Hitam, Kunci Motor...'),
            const SizedBox(height: 25),

            // --- KATEGORI ---
            const Text(
              'Kategori',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildDropdown([
              'Elektronik',
              'Dokumen/Kartu',
              'Aksesoris/Tas',
              'Kunci',
              'Lainnya',
            ], 'Pilih kategori barang'),
            const SizedBox(height: 25),

            // --- LOKASI ---
            const Text(
              'Lokasi Kejadian',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildTextField('Lokasi terakhir dilihat / ditemukan...'),
            const SizedBox(height: 25),

            // --- DESKRIPSI ---
            const Text(
              'Deskripsi Tambahan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              'Sebutkan ciri-ciri khusus (warna, merk, isi dompet, dll)...',
              maxLines: 4,
            ),
            const SizedBox(height: 25),

            // --- UPLOAD FOTO ---
            const Text(
              'Foto Barang (Jika Ada)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                  style: BorderStyle.none,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ketuk untuk tambah foto',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- TOMBOL KIRIM ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Kembali ke Beranda setelah klik Kirim
                  Navigator.pop(context);

                  // Munculkan pesan sukses kecil di bawah layar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Laporan berhasil dikirim!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
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

  // WIDGET BANTUAN: Untuk Form Input Teks
  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextField(
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
  Widget _buildDropdown(List<String> items, String hint) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      hint: Text(
        hint,
        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (_) {}, // Nanti diisi logika untuk menyimpan pilihan
    );
  }
}

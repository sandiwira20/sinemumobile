import 'package:flutter/material.dart';

class DetailBarangPage extends StatelessWidget {
  final String title;
  final String category;
  final String time;
  final String location;
  final String status;
  final List<Color> imageGradient;

  const DetailBarangPage({
    super.key,
    required this.title,
    required this.category,
    required this.time,
    required this.location,
    required this.status,
    required this.imageGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Detail Barang',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Barang (Pakai Gradient Sementara Biar Nyambung sama Card)
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: imageGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 80,
                  color: Colors.white54,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Status (Temuan / Hilang)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: status == 'TEMUAN'
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFFE74C3C),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Judul Barang
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Info Kategori & Waktu
                  Row(
                    children: [
                      const Icon(
                        Icons.label_outline,
                        size: 16,
                        color: Color(0xFF4A90E2),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        category,
                        style: const TextStyle(
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(time, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Info Lokasi
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        location,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Divider(),
                  const SizedBox(height: 15),

                  // Deskripsi
                  const Text(
                    'Deskripsi Barang',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ini adalah deskripsi sementara. Nanti kalau sudah tersambung dengan backend Laravel SiNemu, teks ini akan menampilkan rincian detail barang secara otomatis dari database.',
                    style: TextStyle(color: Colors.black87, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Tombol Aksi di Bawah Layar
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Memproses data $title...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A202C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                status == 'TEMUAN' ? 'KLAIM BARANG INI' : 'SAYA MENEMUKAN INI',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

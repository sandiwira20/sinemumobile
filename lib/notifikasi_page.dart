import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // --- HEADER NOTIFIKASI ---
              Row(
                children: [
                  const Icon(Icons.arrow_back, color: Colors.grey),
                  const SizedBox(width: 15),
                  const Text(
                    'Notifikasi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    'TANDAI DIBACA',
                    style: TextStyle(
                      color: const Color(0xFF4A90E2).withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- DAFTAR NOTIFIKASI ---
              _buildNotifCard(
                title: 'Barang Ditemukan!',
                time: '2 mnt yang lalu',
                description:
                    'Seseorang menemukan kunci mobil Anda di sekitar Taman Bungkul, Surabaya.',
                isUnread: true,
              ),
              _buildNotifCard(
                title: 'Laporan Baru',
                time: '1 jam yang lalu',
                description:
                    'Ada laporan kehilangan Dompet di Kecamatan Gubeng yang sesuai dengan area pencarian Anda.',
              ),
              _buildNotifCard(
                title: 'Pembaruan Sistem',
                time: 'Kemarin',
                description:
                    'Sinemu kini mendukung pencarian barang elektronik dengan fitur verifikasi nomor seri.',
              ),
              _buildNotifCard(
                title: 'Barang Terverifikasi',
                time: '2 hari yang lalu',
                description:
                    'Laporan penemuan Tas Ransel Anda telah diverifikasi oleh admin. Silakan cek detailnya.',
              ),
              _buildNotifCard(
                title: 'Selamat Bergabung!',
                time: '3 hari yang lalu',
                description:
                    'Terima kasih telah menggunakan Sinemu. Mulailah mencari atau membantu orang lain menemukan barang mereka.',
              ),

              const SizedBox(height: 20),
              // --- TEKS BAWAH ---
              const Text(
                'TIDAK ADA LAGI NOTIFIKASI',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 50), // Spasi bawah biar aman dari menu
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET BANTUAN: Cetak Kartu Notifikasi
  Widget _buildNotifCard({
    required String title,
    required String time,
    required String description,
    bool isUnread = false, // Default-nya dibaca (false)
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Text(
                    time,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  if (isUnread) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4A90E2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

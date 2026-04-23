import 'package:flutter/material.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BAGIAN 1: SEARCH BAR & PROFILE ---
              Row(
                children: [
                  Image.asset(
                    'assets/images/logosinemu.png',
                    height: 35,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Text(
                            'Cari barang...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- BAGIAN 2: KOTAK HALO ANDI ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'Halo, ',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'Andi',
                            style: TextStyle(color: Color(0xFF4A90E2)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Apa ada barang yang hilang?',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            'Lapor',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C9CE1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.search,
                            color: Colors.black87,
                            size: 20,
                          ),
                          label: const Text(
                            'Cari',
                            style: TextStyle(color: Colors.black87),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- BAGIAN 3: BARANG TEMUAN ---
              _buildSectionHeader(
                icon: Icons.inventory_2_outlined,
                iconColor: Colors.green,
                title: 'Barang Temuan',
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildItemCard(
                      badgeText: 'TEMUAN',
                      badgeColor: const Color(0xFF2ECC71),
                      imageGradient: const [
                        Color(0xFFF39C12),
                        Color(0xFFF1C40F),
                      ],
                      category: 'OTOMOTIF',
                      time: '2 Jam Lalu',
                      title: 'Kunci Mobil Honda',
                      location: 'Parkiran Minimarket',
                      buttonText: 'KLAIM BARANG',
                    ),
                    const SizedBox(width: 15),
                    _buildItemCard(
                      badgeText: 'TEMUAN',
                      badgeColor: const Color(0xFF2ECC71),
                      imageGradient: const [
                        Color(0xFF7F8C8D),
                        Color(0xFFBDC3C7),
                      ],
                      category: 'GADGET',
                      time: '5 Jam Lalu',
                      title: 'iPhone 13 Hitam',
                      location: 'Halte Bis Sentral',
                      buttonText: 'KLAIM BARANG',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- BAGIAN 4: BARANG HILANG ---
              _buildSectionHeader(
                icon: Icons.search_off,
                iconColor: Colors.redAccent,
                title: 'Barang Hilang',
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildItemCard(
                      badgeText: 'HILANG',
                      badgeColor: const Color(0xFFE74C3C),
                      imageGradient: const [
                        Color(0xFF1ABC9C),
                        Color(0xFF16A085),
                      ],
                      category: 'AKSESORIS',
                      time: '1 Hari Lalu',
                      title: 'Dompet Kulit Coklat',
                      location: 'Area Kantin Kampus',
                      buttonText: 'BANTU CARI',
                    ),
                    const SizedBox(width: 15),
                    _buildItemCard(
                      badgeText: 'HILANG',
                      badgeColor: const Color(0xFFE74C3C),
                      imageGradient: const [
                        Color(0xFF34495E),
                        Color(0xFF2C3E50),
                      ],
                      category: 'HEWAN',
                      time: '2 Hari Lalu',
                      title: 'Anjing Golden',
                      location: 'Taman Kota',
                      buttonText: 'BANTU CARI',
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 100,
              ), // Spasi kosong di bawah biar gak ketutupan bottom nav
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET BANTUAN: Buat bikin Judul Bagian (Contoh: Barang Temuan & Lihat Semua)
  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        const Text(
          'Lihat Semua',
          style: TextStyle(
            color: Color(0xFF4A90E2),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // WIDGET BANTUAN: Buat bikin Kartu Barangnya
  Widget _buildItemCard({
    required String badgeText,
    required Color badgeColor,
    required List<Color> imageGradient,
    required String category,
    required String time,
    required String title,
    required String location,
    required String buttonText,
  }) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar & Badge
          Stack(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: imageGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Info Detail
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xFF4A90E2),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A202C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

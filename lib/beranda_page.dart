import 'dart:convert'; // Untuk menerjemahkan JSON
import 'package:http/http.dart' as http; // Kurir pengantar pesan
import 'package:flutter/material.dart';
import 'pencarian_page.dart';
import 'akun_page.dart';
import 'lapor_page.dart';
import 'daftar_barang_page.dart';
import 'detail_barang_page.dart';

// UBAH JADI STATEFUL WIDGET BIAR BISA NAMPILIN DATA DINAMIS
class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  bool isLoading = true; // Status loading
  String pesanServer = "Menghubungkan ke Dapur Laravel...";
  List barangTemuan = [];
  List barangHilang = [];

  @override
  void initState() {
    super.initState();
    _ambilDataDariLaravel(); // Panggil fungsi saat halaman pertama kali dibuka
  }

  // --- FUNGSI AJAIB UNTUK MENGAMBIL DATA ---
  Future<void> _ambilDataDariLaravel() async {
    try {
      // 10.0.2.2 adalah kode rahasia emulator untuk mengakses localhost laptop
      final url = Uri.parse('http://10.0.2.2:8000/api/tes-barang');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Terjemahkan JSON
        final semuaBarang = data['data_barang'] as List;

        setState(() {
          pesanServer = data['pesan']; // Ambil pesan sapaan dari Laravel
          // Pisahkan mana yang temuan, mana yang hilang
          barangTemuan = semuaBarang
              .where((b) => b['status'] == 'TEMUAN')
              .toList();
          barangHilang = semuaBarang
              .where((b) => b['status'] == 'HILANG')
              .toList();
          isLoading = false; // Matikan loading
        });
      }
    } catch (e) {
      setState(() {
        pesanServer = "Gagal nyambung Bang! Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BAGIAN 1: SEARCH BAR & PROFILE (SAMA SEPERTI SEBELUMNYA) ---
              Row(
                children: [
                  Image.asset(
                    'assets/images/logosinemu.png',
                    height: 35,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PencarianPage(),
                        ),
                      ),
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
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AkunPage()),
                    ),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- BAGIAN 2: KOTAK HALO ---
              Container(
                width: double.infinity,
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
                    // Teks ini sekarang ngambil dari Laravel!
                    Text(
                      isLoading ? "Lagi mesen data..." : pesanServer,
                      style: TextStyle(
                        color: isLoading ? Colors.orange : Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LaporPage(),
                            ),
                          ),
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
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PencarianPage(),
                            ),
                          ),
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

              // JIKA SEDANG LOADING, TAMPILKAN SPINNER
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                // --- BAGIAN 3: BARANG TEMUAN ---
                _buildSectionHeader(
                  icon: Icons.inventory_2_outlined,
                  iconColor: Colors.green,
                  title: 'Barang Temuan',
                  onTapLihatSemua: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DaftarBarangPage(
                        kategori: 'Temuan',
                        warnaTema: Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    // MAPPING DATA DARI LARAVEL
                    children: barangTemuan.map((barang) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: _buildItemCard(
                          badgeText: barang['status'],
                          badgeColor: const Color(0xFF2ECC71),
                          imageGradient: const [
                            Color(0xFFF39C12),
                            Color(0xFFF1C40F),
                          ],
                          category: barang['kategori'],
                          time: 'Baru saja',
                          title: barang['nama'],
                          location: 'Dari Database',
                          buttonText: 'KLAIM BARANG',
                          onTapButton: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailBarangPage(
                                title: barang['nama'],
                                category: barang['kategori'],
                                time: 'Baru Saja',
                                location: 'Dari Database',
                                status: barang['status'],
                                imageGradient: const [
                                  Color(0xFFF39C12),
                                  Color(0xFFF1C40F),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30),

                // --- BAGIAN 4: BARANG HILANG ---
                _buildSectionHeader(
                  icon: Icons.search_off,
                  iconColor: Colors.redAccent,
                  title: 'Barang Hilang',
                  onTapLihatSemua: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DaftarBarangPage(
                        kategori: 'Hilang',
                        warnaTema: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    // MAPPING DATA DARI LARAVEL
                    children: barangHilang.map((barang) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: _buildItemCard(
                          badgeText: barang['status'],
                          badgeColor: const Color(0xFFE74C3C),
                          imageGradient: const [
                            Color(0xFF1ABC9C),
                            Color(0xFF16A085),
                          ],
                          category: barang['kategori'],
                          time: 'Kemarin',
                          title: barang['nama'],
                          location: 'Dari Database',
                          buttonText: 'BANTU CARI',
                          onTapButton: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailBarangPage(
                                title: barang['nama'],
                                category: barang['kategori'],
                                time: 'Kemarin',
                                location: 'Dari Database',
                                status: barang['status'],
                                imageGradient: const [
                                  Color(0xFF1ABC9C),
                                  Color(0xFF16A085),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET BANTUAN SAMA SEPERTI SEBELUMNYA
  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTapLihatSemua,
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
        GestureDetector(
          onTap: onTapLihatSemua,
          child: const Text(
            'Lihat Semua',
            style: TextStyle(
              color: Color(0xFF4A90E2),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard({
    required String badgeText,
    required Color badgeColor,
    required List<Color> imageGradient,
    required String category,
    required String time,
    required String title,
    required String location,
    required String buttonText,
    required VoidCallback onTapButton,
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
                    onPressed: onTapButton,
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

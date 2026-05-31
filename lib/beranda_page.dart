import 'package:flutter/material.dart';

import 'pencarian_page.dart';
import 'akun_page.dart';
import 'lapor_page.dart';
import 'daftar_barang_page.dart';
import 'detail_barang_page.dart';
import 'core/network/api_client.dart';
import 'features/laporan/models/laporan_model.dart';
import 'features/laporan/services/laporan_service.dart';
import 'user_data.dart';

// UBAH JADI STATEFUL WIDGET BIAR BISA NAMPILIN DATA DINAMIS
class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  static const int _homeItemLimit = 5;

  final LaporanService _laporanService = LaporanService();

  bool isLoading = true; // Status loading
  String pesanServer = "Memuat laporan terbaru...";
  String? errorMessage;
  List<LaporanModel> barangTemuan = [];
  List<LaporanModel> barangHilang = [];

  @override
  void initState() {
    super.initState();
    _ambilDataLaporan(); // Panggil fungsi saat halaman pertama kali dibuka
  }

  Future<void> _ambilDataLaporan() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      pesanServer = "Memuat laporan terbaru...";
    });

    try {
      final laporan = await _laporanService.getLaporanPublik();
      if (!mounted) return;

      setState(() {
        barangTemuan = laporan
            .where((item) => item.isTemuan)
            .take(_homeItemLimit)
            .toList();
        barangHilang = laporan
            .where((item) => item.isHilang)
            .take(_homeItemLimit)
            .toList();
        pesanServer = "Laporan publik terbaru sudah dimuat.";
        isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.statusCode == 401
            ? 'Sesi login sudah berakhir. Silakan login ulang.'
            : error.message;
        pesanServer = "Gagal memuat laporan.";
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Gagal memuat laporan terbaru.';
        pesanServer = "Gagal memuat laporan.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = UserData.nama.trim().isEmpty
        ? 'Pengguna'
        : UserData.nama.trim();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _ambilDataLaporan,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                        MaterialPageRoute(
                          builder: (context) => const AkunPage(),
                        ),
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
                        text: TextSpan(
                          text: 'Halo, ',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: userName,
                              style: const TextStyle(color: Color(0xFF4A90E2)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Teks ini sekarang ngambil dari Laravel!
                      Text(
                        isLoading ? "Lagi mesen data..." : pesanServer,
                        style: TextStyle(
                          color: isLoading
                              ? Colors.orange
                              : errorMessage != null
                              ? Colors.red
                              : Colors.green,
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
                else if (errorMessage != null)
                  _buildErrorState()
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
                  _buildHorizontalReports(
                    reports: barangTemuan,
                    emptyMessage: 'Belum ada laporan temuan.',
                    badgeColor: const Color(0xFF2ECC71),
                    imageGradient: const [Color(0xFFF39C12), Color(0xFFF1C40F)],
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
                  _buildHorizontalReports(
                    reports: barangHilang,
                    emptyMessage: 'Belum ada laporan hilang.',
                    badgeColor: const Color(0xFFE74C3C),
                    imageGradient: const [Color(0xFF1ABC9C), Color(0xFF16A085)],
                  ),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
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
            errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _ambilDataLaporan,
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalReports({
    required List<LaporanModel> reports,
    required String emptyMessage,
    required Color badgeColor,
    required List<Color> imageGradient,
  }) {
    if (reports.isEmpty) {
      return _buildEmptySection(emptyMessage);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: reports.map((laporan) {
          return Padding(
            padding: const EdgeInsets.only(right: 15),
            child: _buildItemCard(
              badgeText: laporan.jenisBadge,
              badgeColor: badgeColor,
              imageGradient: imageGradient,
              category: laporan.kategori,
              time: laporan.tanggalDisplay,
              title: laporan.namaBarang,
              location: '${laporan.wilayah} - ${laporan.lokasi}',
              imageUrl: laporan.imageUrl,
              buttonText: 'LIHAT DETAIL',
              onTapButton: () => _openDetail(laporan, imageGradient),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(message, style: const TextStyle(color: Colors.grey)),
    );
  }

  Future<void> _openDetail(
    LaporanModel laporan,
    List<Color> imageGradient,
  ) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailBarangPage(
          initialLaporan: laporan,
          loadRemoteDetail: false,
          reportId: laporan.numericId,
          reportType: laporan.type,
          title: laporan.namaBarang,
          category: laporan.kategori,
          time: laporan.tanggalDisplay,
          location: '${laporan.wilayah} - ${laporan.lokasi}',
          status: laporan.jenisBadge,
          imageGradient: imageGradient,
          imageUrl: laporan.imageUrl,
          description: laporan.deskripsi,
          reportStatus: laporan.status,
          showActionButton: false,
        ),
      ),
    );

    if (changed == true && mounted) {
      _ambilDataLaporan();
    }
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
            color: iconColor.withValues(alpha: 0.1),
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
    required String imageUrl,
    required String buttonText,
    required VoidCallback onTapButton,
  }) {
    return GestureDetector(
      onTap: onTapButton,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildReportImage(
                    imageUrl: imageUrl,
                    imageGradient: imageGradient,
                    placeholderIcon: Icons.image_outlined,
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
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
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
      ),
    );
  }

  Widget _buildReportImage({
    required String imageUrl,
    required List<Color> imageGradient,
    required IconData placeholderIcon,
  }) {
    final normalizedImageUrl = imageUrl.trim();
    if (normalizedImageUrl.isEmpty) {
      return _buildImagePlaceholder(imageGradient, placeholderIcon);
    }

    return Image.network(
      normalizedImageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return _buildImagePlaceholder(
          imageGradient,
          placeholderIcon,
          isLoading: true,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildImagePlaceholder(imageGradient, placeholderIcon);
      },
    );
  }

  Widget _buildImagePlaceholder(
    List<Color> imageGradient,
    IconData placeholderIcon, {
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: imageGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(placeholderIcon, size: 44, color: Colors.white54),
      ),
    );
  }
}

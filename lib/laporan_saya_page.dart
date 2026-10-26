import 'package:flutter/material.dart';

import 'panduang_pengambilan_page.dart';
import 'core/network/api_client.dart';
import 'features/klaim/models/klaim_model.dart';
import 'features/klaim/services/klaim_service.dart';
import 'features/laporan/models/laporan_model.dart';
import 'features/laporan/services/laporan_service.dart';

class LaporanSayaPage extends StatefulWidget {
  const LaporanSayaPage({super.key});

  @override
  State<LaporanSayaPage> createState() => _LaporanSayaPageState();
}

class _LaporanSayaPageState extends State<LaporanSayaPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late final LaporanService _laporanService;
  late final KlaimService _klaimService;

  bool _isLoadingLaporan = true;
  bool _isLoadingKlaim = true;

  String? _errorLaporan;
  String? _errorKlaim;

  List<LaporanModel> _laporanHilang = [];
  List<LaporanModel> _laporanTemuan = [];
  List<KlaimModel> _klaims = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    final apiClient = ApiClient();

    _laporanService = LaporanService(apiClient: apiClient);
    _klaimService = KlaimService(apiClient: apiClient);

    _loadLaporan();
    _loadKlaim();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLaporan() async {
    if (mounted) {
      setState(() {
        _isLoadingLaporan = true;
        _errorLaporan = null;
      });
    }

    try {
      final laporan = await _laporanService.getLaporan();

      if (!mounted) return;

      setState(() {
        _laporanHilang = laporan.where((item) => item.isHilang).toList();

        _laporanTemuan = laporan.where((item) => item.isTemuan).toList();

        _isLoadingLaporan = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorLaporan = 'Gagal memuat laporan: $e';
        _isLoadingLaporan = false;
      });
    }
  }

  Future<void> _loadKlaim() async {
    if (mounted) {
      setState(() {
        _isLoadingKlaim = true;
        _errorKlaim = null;
      });
    }

    try {
      final klaims = await _klaimService.getKlaim();

      debugPrint('JUMLAH KLAIM: ${klaims.length}');
      for (final klaim in klaims) {
        debugPrint(
          'KLAIM ID: ${klaim.id}, '
          'BARANG ID: ${klaim.barangId}, '
          'NAMA: ${klaim.namaBarang}',
        );
      }

      if (!mounted) return;

      setState(() {
        _klaims = klaims;
        _isLoadingKlaim = false;
      });
    } catch (e, stackTrace) {
      debugPrint('ERROR LOAD KLAIM: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _errorKlaim = 'Gagal memuat riwayat klaim: $e';
        _isLoadingKlaim = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Laporan Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Laporan Hilang (${_laporanHilang.length})'),
            Tab(text: 'Laporan Temuan (${_laporanTemuan.length})'),
            Tab(text: 'Riwayat Klaim (${_klaims.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLaporanTab(),
          _buildLaporanTemuanTab(),
          _buildKlaimTab(),
        ],
      ),
    );
  }

  // ============================================================
  // TAB LAPORAN HILANG
  // ============================================================

  Widget _buildLaporanTab() {
    if (_isLoadingLaporan) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorLaporan != null) {
      return _buildErrorState(_errorLaporan!, _loadLaporan);
    }

    if (_laporanHilang.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        pesan: 'Belum ada laporan barang hilang.',
        onRefresh: _loadLaporan,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLaporan,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _laporanHilang.length,
        itemBuilder: (context, index) {
          return _buildLaporanCard(_laporanHilang[index]);
        },
      ),
    );
  }

  // ============================================================
  // TAB LAPORAN TEMUAN
  // ============================================================

  Widget _buildLaporanTemuanTab() {
    if (_isLoadingLaporan) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorLaporan != null) {
      return _buildErrorState(_errorLaporan!, _loadLaporan);
    }

    if (_laporanTemuan.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inventory_2_outlined,
        pesan: 'Belum ada laporan barang temuan.',
        onRefresh: _loadLaporan,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLaporan,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _laporanTemuan.length,
        itemBuilder: (context, index) {
          return _buildLaporanCard(_laporanTemuan[index]);
        },
      ),
    );
  }

  // ============================================================
  // KARTU LAPORAN
  // ============================================================

  Widget _buildLaporanCard(LaporanModel laporan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    laporan.namaBarang,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _statusBadge(laporan.status),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.location_on_outlined,
              'Wilayah',
              laporan.wilayah,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Tanggal',
              laporan.tanggalDisplay,
            ),
            if (laporan.deskripsi.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.description_outlined,
                'Deskripsi',
                laporan.deskripsi,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TAB RIWAYAT KLAIM
  // ============================================================

  Widget _buildKlaimTab() {
    if (_isLoadingKlaim) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorKlaim != null) {
      return _buildErrorState(_errorKlaim!, _loadKlaim);
    }

    if (_klaims.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_turned_in_outlined,
        pesan: 'Belum ada riwayat klaim.',
        onRefresh: _loadKlaim,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadKlaim,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _klaims.length,
        itemBuilder: (context, index) {
          return _buildKlaimCard(_klaims[index]);
        },
      ),
    );
  }

  // ============================================================
  // KARTU KLAIM
  // ============================================================

  Widget _buildKlaimCard(KlaimModel klaim) {
    final disetujui = klaim.status.trim().toLowerCase() == 'disetujui';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (!disetujui) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Panduan pengambilan tersedia setelah klaim disetujui.',
                ),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                final laporan = _cariLaporanTemuan(klaim);

                debugPrint('ID KLAIM: ${klaim.id}');
                debugPrint('BARANG ID KLAIM: ${klaim.barangId}');
                debugPrint('LAPORAN DITEMUKAN: ${laporan != null}');
                debugPrint('FOTO LAPORAN: ${laporan?.imageUrl}');
                debugPrint('KATEGORI: ${laporan?.kategori}');
                debugPrint('LOKASI: ${laporan?.lokasi}');
                debugPrint('DESKRIPSI: ${laporan?.deskripsi}');

                final ciriKhusus =
                    [laporan?.warnaDominan, laporan?.merek, laporan?.nomorSeri]
                        .whereType<String>()
                        .where((s) => s.trim().isNotEmpty)
                        .join(', ');

                return PanduanPengambilanPage(
                  namaBarang: klaim.namaBarang,
                  wilayah: _wilayahKlaim(klaim),
                  nomorKlaim: klaim.id,
                  statusKlaim: klaim.statusLabel,
                  kontak: klaim.kontak,
                  tanggal: klaim.tanggalDisplay,
                  keterangan: klaim.alasan,

                  // Rincian barang temuan
                  fotoBarang: klaim.fotoBarang.isNotEmpty
                      ? klaim.fotoBarang
                      : (laporan?.imageUrl ?? ''),
                  kategoriBarang: laporan?.kategori == '-'
                      ? ''
                      : (laporan?.kategori ?? ''),
                  lokasiDitemukan: laporan?.lokasi == '-'
                      ? ''
                      : (laporan?.lokasi ?? ''),
                  tanggalTemuan: laporan?.tanggal == '-'
                      ? ''
                      : (laporan?.tanggal ?? ''),
                  deskripsiBarang: laporan?.deskripsi == '-'
                      ? ''
                      : (laporan?.deskripsi ?? ''),
                  ciriKhusus: ciriKhusus,

                  // Kode pengambilan dan informasi posko
                  kodePengambilan: klaim.kodePengambilan.isNotEmpty
                      ? klaim.kodePengambilan
                      : '#KLM-${klaim.id.padLeft(5, '0')}',
                  namaPosko: klaim.namaPosko,
                  alamatPosko: klaim.alamatPosko,
                  wilayahPosko: klaim.wilayahPosko.isNotEmpty
                      ? klaim.wilayahPosko
                      : _wilayahKlaim(klaim),
                  jamLayanan: klaim.jamLayanan,
                  penanggungJawab: klaim.penanggungJawab,
                  catatanPosko: klaim.catatanPosko,

                  // Informasi pengaju
                  namaPengambil: '',
                  emailPengambil: '',
                  buktiKepemilikan: klaim.alasan,
                );
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_outlined,
                      color: Colors.blue,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          klaim.namaBarang,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nomor klaim: ${klaim.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusKlaimBadge(klaim.statusLabel),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.calendar_today_outlined,
                'Tanggal klaim',
                klaim.tanggalDisplay,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.location_on_outlined,
                'Wilayah',
                _wilayahKlaim(klaim).isEmpty ? '-' : _wilayahKlaim(klaim),
              ),
              if (disetujui) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.touch_app_outlined,
                      size: 18,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Ketuk untuk melihat panduan pengambilan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.green),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CARI WILAYAH KLAIM
  // ============================================================

  LaporanModel? _cariLaporanTemuan(KlaimModel klaim) {
    final barangId = klaim.barangId.trim();

    for (final laporan in _laporanTemuan) {
      if (laporan.id.trim() == barangId &&
          laporan.namaBarang.trim().toLowerCase() ==
              klaim.namaBarang.trim().toLowerCase()) {
        debugPrint('LAPORAN COCOK: ${laporan.namaBarang}');
        debugPrint('ID LAPORAN: ${laporan.id}');
        debugPrint('FOTO: ${laporan.imageUrl}');
        return laporan;
      }
    }

    debugPrint('LAPORAN YANG SESUAI TIDAK DITEMUKAN');
    return null;
  }

  String _wilayahKlaim(KlaimModel klaim) {
    final wilayahKlaim = klaim.wilayah.trim();

    if (wilayahKlaim.isNotEmpty) {
      return wilayahKlaim;
    }

    final laporan = _cariLaporanTemuan(klaim);
    return laporan?.wilayah ?? '';
  }

  // ============================================================
  // BADGE STATUS
  // ============================================================

  Widget _statusBadge(String status) {
    final color = _statusKlaimColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? 'Tidak diketahui' : status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statusKlaimBadge(String status) {
    final color = _statusKlaimColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? 'Tidak diketahui' : status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _statusKlaimColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'disetujui':
        return Colors.green;
      case 'menunggu':
      case 'pending':
      case 'diproses':
        return Colors.orange;
      case 'ditolak':
        return Colors.red;
      case 'selesai':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
        const Text(': '),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState({
    required IconData icon,
    required String pesan,
    required Future<void> Function() onRefresh,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 72, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      pesan,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tarik layar ke bawah untuk memuat ulang.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(String pesan, Future<void> Function() onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 12),
            Text(pesan, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

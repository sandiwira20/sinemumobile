import 'package:flutter/material.dart';

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
  final LaporanService _laporanService = LaporanService();
  final KlaimService _klaimService = KlaimService();

  // State laporan
  bool _isLoadingLaporan = true;
  String? _errorLaporan;
  List<LaporanModel> _laporans = [];

  // State klaim
  bool _isLoadingKlaim = true;
  String? _errorKlaim;
  List<KlaimModel> _klaims = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLaporan();
    _loadKlaim();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLaporan() async {
    setState(() {
      _isLoadingLaporan = true;
      _errorLaporan = null;
    });

    try {
      final laporans = await _laporanService.getLaporan();
      if (!mounted) return;
      // Filter hanya laporan milik user (isOwner = true) dan type hilang
      final milikSaya = laporans.where((l) => l.isOwner && l.isHilang).toList();
      setState(() {
        _laporans = milikSaya;
        _isLoadingLaporan = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorLaporan = _errorMsg(e);
        _isLoadingLaporan = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorLaporan = 'Gagal memuat laporan.';
        _isLoadingLaporan = false;
      });
    }
  }

  Future<void> _loadKlaim() async {
    setState(() {
      _isLoadingKlaim = true;
      _errorKlaim = null;
    });

    try {
      final klaims = await _klaimService.getKlaim();
      if (!mounted) return;
      setState(() {
        _klaims = klaims;
        _isLoadingKlaim = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorKlaim = _errorMsg(e);
        _isLoadingKlaim = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorKlaim = 'Gagal memuat riwayat klaim.';
        _isLoadingKlaim = false;
      });
    }
  }

  String _errorMsg(ApiException e) {
    return switch (e.statusCode) {
      401 => 'Sesi login sudah berakhir. Silakan login ulang.',
      404 => 'Data tidak ditemukan.',
      _ => e.message,
    };
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
          'Laporan Saya',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4A90E2),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4A90E2),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_outlined, size: 18),
                  const SizedBox(width: 6),
                  const Text('Laporan Hilang'),
                  if (_laporans.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildBadge(_laporans.length),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_turned_in_outlined, size: 18),
                  const SizedBox(width: 6),
                  const Text('Riwayat Klaim'),
                  if (_klaims.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildBadge(_klaims.length),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Laporan Hilang
          _buildLaporanTab(),
          // Tab 2: Riwayat Klaim
          _buildKlaimTab(),
        ],
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =====================
  // TAB LAPORAN HILANG
  // =====================
  Widget _buildLaporanTab() {
    if (_isLoadingLaporan) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorLaporan != null) {
      return _buildErrorState(_errorLaporan!, _loadLaporan);
    }

    if (_laporans.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        pesan: 'Belum ada laporan barang hilang.',
        onRefresh: _loadLaporan,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLaporan,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _laporans.length,
        itemBuilder: (context, index) => _buildLaporanCard(_laporans[index]),
      ),
    );
  }

  Widget _buildLaporanCard(LaporanModel laporan) {
    final statusColor = _statusLaporanColor(laporan.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.search_off_outlined,
                    color: Colors.orange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        laporan.namaBarang,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        laporan.kategori,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLaporanLabel(laporan.status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on_outlined, laporan.lokasi),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.map_outlined, laporan.wilayah),
            const SizedBox(height: 6),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              laporan.tanggalDisplay,
            ),
          ],
        ),
      ),
    );
  }

  Color _statusLaporanColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('disetujui') || s.contains('approved')) {
      return Colors.green;
    }
    if (s.contains('ditolak') || s.contains('rejected')) return Colors.red;
    if (s.contains('pending') || s.contains('submitted')) {
      return Colors.orange;
    }
    return Colors.blue;
  }

  String _statusLaporanLabel(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  // =====================
  // TAB RIWAYAT KLAIM
  // =====================
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
        padding: const EdgeInsets.all(16),
        itemCount: _klaims.length,
        itemBuilder: (context, index) => _buildKlaimCard(_klaims[index]),
      ),
    );
  }

  Widget _buildKlaimCard(KlaimModel klaim) {
    final statusColor = _statusKlaimColor(klaim.status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: Color(0xFF4A90E2),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    klaim.namaBarang,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    klaim.statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.notes_outlined, klaim.alasan),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.phone_outlined, klaim.kontak),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.calendar_today_outlined, klaim.tanggalDisplay),
          ],
        ),
      ),
    );
  }

  Color _statusKlaimColor(String status) {
    return switch (status.toLowerCase()) {
      'disetujui' => Colors.green,
      'ditolak' => Colors.red,
      _ => Colors.orange,
    };
  }

  // =====================
  // HELPER WIDGET
  // =====================
  Widget _buildInfoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String pesan,
    required VoidCallback onRefresh,
  }) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 160),
          Icon(icon, color: Colors.grey, size: 46),
          const SizedBox(height: 12),
          Center(
            child: Text(pesan, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 42),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

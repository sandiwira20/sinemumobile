import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'detail_barang_page.dart';
import 'features/laporan/models/laporan_model.dart';
import 'features/laporan/services/laporan_service.dart';

class DaftarBarangPage extends StatefulWidget {
  final String kategori;
  final Color warnaTema;

  const DaftarBarangPage({
    super.key,
    required this.kategori,
    required this.warnaTema,
  });

  @override
  State<DaftarBarangPage> createState() => _DaftarBarangPageState();
}

class _DaftarBarangPageState extends State<DaftarBarangPage> {
  final LaporanService _laporanService = LaporanService();

  bool _isLoading = true;
  String? _errorMessage;
  List<LaporanModel> _laporans = [];

  @override
  void initState() {
    super.initState();
    _loadLaporan();
  }

  Future<void> _loadLaporan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final laporans = await _laporanService.getLaporanPublik();
      if (!mounted) return;

      setState(() {
        _laporans = laporans;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.statusCode == 401
            ? 'Sesi login sudah berakhir. Silakan login ulang.'
            : error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Gagal memuat daftar laporan.';
        _isLoading = false;
      });
    }
  }

  List<LaporanModel> get _filteredLaporans {
    final filter = widget.kategori.toLowerCase();
    if (filter.contains('hilang')) {
      return _laporans.where((laporan) => laporan.isHilang).toList();
    }

    if (filter.contains('temuan')) {
      return _laporans.where((laporan) => laporan.isTemuan).toList();
    }

    return _laporans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Laporan ${widget.kategori}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: widget.warnaTema,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    final laporans = _filteredLaporans;
    if (laporans.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadLaporan,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: laporans.length,
        itemBuilder: (context, index) {
          return _buildLaporanCard(laporans[index]);
        },
      ),
    );
  }

  Widget _buildLaporanCard(LaporanModel laporan) {
    final badgeColor = laporan.isTemuan ? Colors.green : Colors.redAccent;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: _buildThumbnail(laporan.imageUrl, badgeColor),
        title: Text(
          laporan.namaBarang,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            '${laporan.jenisLabel} | ${laporan.kategori}\n'
            '${laporan.wilayah} - ${laporan.lokasi}\n'
            'Status: ${laporan.status} | ${laporan.tanggalDisplay}',
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () => _openDetail(laporan),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 42),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: _loadLaporan, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Belum ada laporan ${widget.kategori.toLowerCase()}.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Future<void> _openDetail(LaporanModel laporan) async {
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
          imageGradient: laporan.isTemuan
              ? const [Color(0xFFF39C12), Color(0xFFF1C40F)]
              : const [Color(0xFF1ABC9C), Color(0xFF16A085)],
          imageUrl: laporan.imageUrl,
          description: laporan.deskripsi,
          reportStatus: laporan.status,
          showActionButton: false,
        ),
      ),
    );

    if (changed == true && mounted) {
      _loadLaporan();
    }
  }

  Widget _buildThumbnail(String imageUrl, Color badgeColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 60,
        height: 60,
        child: _buildThumbnailImage(imageUrl, badgeColor),
      ),
    );
  }

  Widget _buildThumbnailImage(String imageUrl, Color badgeColor) {
    final normalizedImageUrl = imageUrl.trim();
    if (normalizedImageUrl.isEmpty) {
      return _buildThumbnailPlaceholder(badgeColor);
    }

    return Image.network(
      normalizedImageUrl,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return _buildThumbnailPlaceholder(badgeColor, isLoading: true);
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildThumbnailPlaceholder(badgeColor);
      },
    );
  }

  Widget _buildThumbnailPlaceholder(
    Color badgeColor, {
    bool isLoading = false,
  }) {
    return Container(
      width: 60,
      height: 60,
      color: badgeColor.withValues(alpha: 0.1),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: badgeColor,
                ),
              )
            : Icon(Icons.inventory_2_outlined, color: badgeColor, size: 30),
      ),
    );
  }
}

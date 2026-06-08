import 'package:flutter/material.dart';
import 'core/network/api_client.dart';
import 'detail_barang_page.dart';
import 'features/laporan/models/laporan_model.dart';
import 'features/laporan/services/laporan_service.dart';

class PencarianPage extends StatefulWidget {
  const PencarianPage({super.key});

  @override
  State<PencarianPage> createState() => _PencarianPageState();
}

class _PencarianPageState extends State<PencarianPage> {
  final _searchController = TextEditingController();
  final _laporanService = LaporanService();

  List<LaporanModel> _hasil = [];
  bool _isLoading = false;
  bool _sudahCari = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cari(String keyword) async {
    if (keyword.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _sudahCari = true;
      _errorMessage = null;
      _hasil = [];
    });

    try {
      final hasil = await _laporanService.searchLaporan(keyword);
      if (!mounted) return;
      setState(() {
        _hasil = hasil;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal mencari barang. Coba lagi.';
        _isLoading = false;
      });
    }
  }

  void _openDetail(LaporanModel laporan) {
    final isTemuan = laporan.isTemuan;
    final imageGradient = isTemuan
        ? const [Color(0xFFF39C12), Color(0xFFF1C40F)]
        : const [Color(0xFF1ABC9C), Color(0xFF16A085)];

    Navigator.push(
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: _cari,
            decoration: InputDecoration(
              hintText: 'Cari barang...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _hasil = [];
                          _sudahCari = false;
                          _errorMessage = null;
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.grey),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (v) => setState(() {}),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _cari(_searchController.text),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (!_sudahCari) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Ketik nama barang lalu tekan Enter',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_hasil.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Tidak ada hasil untuk "${_searchController.text}"',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _hasil.length,
      itemBuilder: (context, index) {
        final laporan = _hasil[index];
        return _buildResultCard(laporan);
      },
    );
  }

  Widget _buildResultCard(LaporanModel laporan) {
    final isTemuan = laporan.isTemuan;
    final badgeColor = isTemuan
        ? const Color(0xFF2ECC71)
        : const Color(0xFFE74C3C);
    final imageGradient = isTemuan
        ? const [Color(0xFFF39C12), Color(0xFFF1C40F)]
        : const [Color(0xFF1ABC9C), Color(0xFF16A085)];

    return GestureDetector(
      onTap: () => _openDetail(laporan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gambar
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: laporan.imageUrl.isNotEmpty
                    ? Image.network(
                        laporan.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildImgPlaceholder(imageGradient),
                      )
                    : _buildImgPlaceholder(imageGradient),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            laporan.jenisBadge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          laporan.tanggalDisplay,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      laporan.namaBarang,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      laporan.kategori,
                      style: const TextStyle(
                        color: Color(0xFF4A90E2),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${laporan.wilayah} - ${laporan.lokasi}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImgPlaceholder(List<Color> gradient) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.white54, size: 32),
      ),
    );
  }
}
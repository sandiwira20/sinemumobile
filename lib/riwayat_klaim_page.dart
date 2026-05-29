import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'features/klaim/models/klaim_model.dart';
import 'features/klaim/services/klaim_service.dart';

class RiwayatKlaimPage extends StatefulWidget {
  const RiwayatKlaimPage({super.key});

  @override
  State<RiwayatKlaimPage> createState() => _RiwayatKlaimPageState();
}

class _RiwayatKlaimPageState extends State<RiwayatKlaimPage> {
  final KlaimService _klaimService = KlaimService();

  bool _isLoading = true;
  String? _errorMessage;
  List<KlaimModel> _klaims = [];

  @override
  void initState() {
    super.initState();
    _loadKlaim();
  }

  Future<void> _loadKlaim() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final klaims = await _klaimService.getKlaim();
      if (!mounted) return;

      setState(() {
        _klaims = klaims;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _apiErrorMessage(error);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Gagal memuat riwayat klaim.';
        _isLoading = false;
      });
    }
  }

  String _apiErrorMessage(ApiException error) {
    return switch (error.statusCode) {
      401 => 'Sesi login sudah berakhir. Silakan login ulang.',
      404 => 'Klaim tidak ditemukan.',
      _ => error.message,
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
          'Riwayat Klaim',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
      return _buildErrorState();
    }

    if (_klaims.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadKlaim,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),
            Icon(Icons.assignment_outlined, color: Colors.grey, size: 46),
            SizedBox(height: 12),
            Center(
              child: Text(
                'Belum ada riwayat klaim.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadKlaim,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _klaims.length,
        itemBuilder: (context, index) => _buildKlaimCard(_klaims[index]),
      ),
    );
  }

  Widget _buildKlaimCard(KlaimModel klaim) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.assignment_turned_in_outlined,
            color: Color(0xFF4A90E2),
          ),
        ),
        title: Text(
          klaim.namaBarang,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Status: ${klaim.statusLabel}\n'
            'Alasan: ${klaim.alasan}\n'
            'Kontak: ${klaim.kontak}\n'
            'Tanggal: ${klaim.tanggalDisplay}',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showDetailKlaim(klaim),
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
            TextButton(onPressed: _loadKlaim, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }

  void _showDetailKlaim(KlaimModel klaim) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _KlaimDetailSheet(
          initialKlaim: klaim,
          klaimService: _klaimService,
        );
      },
    );
  }
}

class _KlaimDetailSheet extends StatefulWidget {
  const _KlaimDetailSheet({
    required this.initialKlaim,
    required this.klaimService,
  });

  final KlaimModel initialKlaim;
  final KlaimService klaimService;

  @override
  State<_KlaimDetailSheet> createState() => _KlaimDetailSheetState();
}

class _KlaimDetailSheetState extends State<_KlaimDetailSheet> {
  bool _isLoading = true;
  String? _errorMessage;
  KlaimModel? _detail;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final klaimId = widget.initialKlaim.numericId;
    if (klaimId == null) {
      setState(() {
        _errorMessage = 'ID klaim tidak valid.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await widget.klaimService.getDetailKlaim(klaimId);
      if (!mounted) return;

      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _apiErrorMessage(error);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Gagal memuat detail klaim.';
        _isLoading = false;
      });
    }
  }

  String _apiErrorMessage(ApiException error) {
    return switch (error.statusCode) {
      401 => 'Sesi login sudah berakhir. Silakan login ulang.',
      404 => 'Klaim tidak ditemukan.',
      _ => error.message,
    };
  }

  @override
  Widget build(BuildContext context) {
    final klaim = _detail ?? widget.initialKlaim;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Detail Klaim',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: _loadDetail,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildInfoRow('Nama Barang', klaim.namaBarang),
            _buildInfoRow('Status Klaim', klaim.statusLabel),
            _buildInfoRow('Alasan', klaim.alasan),
            _buildInfoRow('Kontak', klaim.kontak),
            _buildInfoRow('Tanggal Pengajuan', klaim.tanggalDisplay),
            _buildInfoRow('Status Barang', klaim.statusBarangLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(value.isEmpty ? '-' : value),
        ],
      ),
    );
  }
}

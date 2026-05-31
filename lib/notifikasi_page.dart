import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'features/notifikasi/models/notifikasi_model.dart';
import 'features/notifikasi/services/notifikasi_service.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  final NotifikasiService _notifikasiService = NotifikasiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<NotifikasiModel> _notifikasis = [];
  final Set<int> _markingIds = {};

  @override
  void initState() {
    super.initState();
    _loadNotifikasi();
  }

  Future<void> _loadNotifikasi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifikasis = await _notifikasiService.getNotifikasi();
      if (!mounted) return;

      setState(() {
        _notifikasis = notifikasis;
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
        _errorMessage = 'Gagal memuat notifikasi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(NotifikasiModel notifikasi) async {
    final id = notifikasi.numericId;
    if (id == null) {
      _showSnackBar('ID notifikasi tidak valid.', isError: true);
      return;
    }

    if (_markingIds.contains(id)) {
      return;
    }

    setState(() => _markingIds.add(id));

    try {
      await _notifikasiService.markAsRead(id);
      if (!mounted) return;

      setState(() {
        _notifikasis = _notifikasis
            .map((item) => item.id == notifikasi.id ? item.markRead() : item)
            .toList();
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnackBar(_apiErrorMessage(error), isError: true);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Gagal menandai notifikasi.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _markingIds.remove(id));
      }
    }
  }

  String _apiErrorMessage(ApiException error) {
    return switch (error.statusCode) {
      401 => 'Sesi login sudah berakhir. Silakan login ulang.',
      404 => 'Notifikasi tidak ditemukan.',
      _ => error.message,
    };
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  int get _unreadCount {
    return _notifikasis.where((item) => !item.dibaca).length;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadNotifikasi,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildBody(),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Notifikasi',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Text(
          '$_unreadCount BELUM DIBACA',
          style: const TextStyle(
            color: Color(0xFF4A90E2),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_notifikasis.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        ..._notifikasis.map(_buildNotifCard),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'TIDAK ADA LAGI NOTIFIKASI',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
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
            TextButton(
              onPressed: _loadNotifikasi,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 90),
        child: Column(
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 46,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text('Belum ada notifikasi.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifCard(NotifikasiModel notifikasi) {
    final id = notifikasi.numericId;
    final isMarking = id != null && _markingIds.contains(id);

    return InkWell(
      onTap: isMarking ? null : () => _markAsRead(notifikasi),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: notifikasi.dibaca ? Colors.white : const Color(0xFFEAF3FF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    notifikasi.judul,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      notifikasi.tanggalDisplay,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (!notifikasi.dibaca) ...[
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
                    if (isMarking) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              notifikasi.pesan,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              notifikasi.dibaca ? 'Sudah dibaca' : 'Belum dibaca',
              style: TextStyle(
                color: notifikasi.dibaca
                    ? Colors.grey
                    : const Color(0xFF4A90E2),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'edit_laporan_hilang_page.dart';
import 'features/klaim/services/klaim_service.dart';
import 'features/laporan/models/laporan_model.dart';
import 'features/laporan/services/laporan_service.dart';

class DetailBarangPage extends StatefulWidget {
  final String title;
  final String category;
  final String time;
  final String location;
  final String status;
  final List<Color> imageGradient;
  final String imageUrl;
  final String description;
  final String? reportStatus;
  final bool showActionButton;
  final int? reportId;
  final String? reportType;
  final LaporanModel? initialLaporan;
  final bool loadRemoteDetail;

  const DetailBarangPage({
    super.key,
    this.initialLaporan,
    this.loadRemoteDetail = true,
    this.reportId,
    this.reportType,
    required this.title,
    required this.category,
    required this.time,
    required this.location,
    required this.status,
    required this.imageGradient,
    this.imageUrl = '',
    this.description = 'Tidak ada deskripsi.',
    this.reportStatus,
    this.showActionButton = false,
  });

  @override
  State<DetailBarangPage> createState() => _DetailBarangPageState();
}

class _DetailBarangPageState extends State<DetailBarangPage> {
  final LaporanService _laporanService = LaporanService();
  final KlaimService _klaimService = KlaimService();

  bool _isLoadingDetail = false;
  bool _isDeleting = false;
  bool _hasChanges = false;
  String? _detailError;
  LaporanModel? _detail;

  bool get _canLoadDetail {
    return widget.loadRemoteDetail &&
        widget.reportId != null &&
        (widget.reportType?.trim().isNotEmpty ?? false);
  }

  bool get _hasFallbackData => widget.title.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _detail = widget.initialLaporan;
    if (_canLoadDetail) {
      _loadDetail();
    }
  }

  Future<void> _loadDetail() async {
    if (!_canLoadDetail) return;

    setState(() {
      _isLoadingDetail = true;
      _detailError = null;
    });

    try {
      final detail = await _laporanService.getDetailLaporan(
        id: widget.reportId!,
        type: widget.reportType!,
      );

      if (!mounted) return;

      setState(() {
        _detail = detail;
        _isLoadingDetail = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _detailError = error.statusCode == 401
            ? 'Sesi login sudah berakhir. Silakan login ulang.'
            : error.message;
        _isLoadingDetail = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _detailError = 'Gagal memuat detail laporan.';
        _isLoadingDetail = false;
      });
    }
  }

  Future<void> _openEditPage() async {
    if (!_canManageHilang) return;

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditLaporanHilangPage(laporan: _currentLaporan),
      ),
    );

    if (updated == true && mounted) {
      setState(() => _hasChanges = true);
      _showSnackBar('Laporan berhasil diperbarui.');
      await _loadDetail();
    }
  }

  Future<void> _confirmDelete() async {
    if (!_canManageHilang) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus laporan?'),
        content: Text('Laporan "$_displayTitle" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteLaporan();
    }
  }

  Future<void> _deleteLaporan() async {
    final reportId = _currentReportId;
    if (reportId == null) {
      _showSnackBar('ID laporan tidak valid.', isError: true);
      return;
    }

    setState(() => _isDeleting = true);

    try {
      await _laporanService.deleteLaporanHilang(id: reportId);

      if (!mounted) return;

      _showSnackBar('Laporan berhasil dihapus.');
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnackBar(_apiErrorMessage(error), isError: true);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Laporan gagal dihapus. Coba lagi.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  // ✅ FIXED: Hapus _isSubmittingKlaim & setState ke parent dari dalam dialog
  Future<void> _openKlaimDialog() async {
    if (!_canKlaimTemuan) return;

    final alasanController = TextEditingController();
    final kontakController = TextEditingController();

    bool? success;

    try {
      success = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          String? errorMessage;
          bool isSubmitting = false;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> submitKlaim() async {
                final alasan = alasanController.text.trim();
                if (alasan.isEmpty) {
                  setDialogState(() {
                    errorMessage = 'Alasan klaim wajib diisi.';
                  });
                  return;
                }

                setDialogState(() {
                  errorMessage = null;
                  isSubmitting = true;
                });

                try {
                  await _klaimService.submitKlaimBarangTemuan(
                    barangId: _currentReportId!,
                    alasan: alasan,
                    kontak: kontakController.text,
                  );

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, true);
                  }
                } on ApiException catch (error) {
                  if (dialogContext.mounted) {
                    setDialogState(() {
                      errorMessage = _klaimErrorMessage(error);
                      isSubmitting = false;
                    });
                  }
                } catch (_) {
                  if (dialogContext.mounted) {
                    setDialogState(() {
                      errorMessage = 'Klaim gagal dikirim. Coba lagi.';
                      isSubmitting = false;
                    });
                  }
                }
                // ✅ TIDAK ada finally setState ke parent di sini
              }

              return AlertDialog(
                title: const Text('Klaim Barang'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: alasanController,
                        enabled: !isSubmitting,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Alasan klaim',
                          hintText:
                              'Contoh: Barang ini milik saya, cirinya ada gantungan biru.',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: kontakController,
                        enabled: !isSubmitting,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Kontak',
                          hintText: 'Nomor HP atau kontak lain',
                        ),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () => Navigator.pop(dialogContext, false),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: isSubmitting ? null : submitKlaim,
                    child: isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Kirim'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      alasanController.dispose();
      kontakController.dispose();
    }

    // ✅ Handle result SETELAH dialog tutup & controller sudah di-dispose
    if (success == true && mounted) {
      _showSnackBar('Klaim berhasil dikirim.');
      if (_canLoadDetail) {
        await _loadDetail();
      } else if (_detail != null) {
        setState(() {
          _hasChanges = true;
          _detail = _detail!.copyWith(
            claimable: false,
            claimBlockReason: 'Klaim sudah berhasil dikirim.',
          );
        });
      }
    }
  }

  String _apiErrorMessage(ApiException error) {
    return switch (error.statusCode) {
      401 => 'Sesi login sudah berakhir. Silakan login ulang.',
      403 => 'Tidak punya akses untuk mengubah laporan ini.',
      404 => 'Laporan tidak ditemukan.',
      _ => error.message,
    };
  }

  String _klaimErrorMessage(ApiException error) {
    return switch (error.statusCode) {
      401 => 'Sesi login sudah berakhir. Silakan login ulang.',
      403 => 'Tidak punya akses untuk klaim barang ini.',
      404 => 'Barang tidak ditemukan.',
      409 => 'Barang sudah diklaim atau klaim sudah pernah diajukan.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _hasChanges),
        ),
        title: const Text(
          'Detail Barang',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildBody() {
    if (_detailError != null && !_hasFallbackData && !_isLoadingDetail) {
      return _buildFullErrorState();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroImage(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailState(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _badgeColor(_displayTypeBadge),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _displayTypeBadge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (_displayReportStatus != null)
                      Text(
                        'Status: $_displayReportStatus',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  _displayTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.label_outline,
                      size: 16,
                      color: Color(0xFF4A90E2),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        _displayCategory,
                        style: const TextStyle(
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      _displayTime,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        _displayLocation,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Divider(),
                const SizedBox(height: 15),
                const Text(
                  'Deskripsi Barang',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  _displayDescription,
                  style: const TextStyle(color: Colors.black87, height: 1.5),
                ),
                if (_claimBlockReason != null) ...[
                  const SizedBox(height: 16),
                  _buildClaimBlockReason(_claimBlockReason!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomActions() {
    if (_canManageHilang) {
      return _buildHilangActions();
    }

    if (_canKlaimTemuan) {
      return _buildKlaimAction();
    }

    return null;
  }

  Widget _buildHilangActions() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isDeleting ? null : _confirmDelete,
                icon: _isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline),
                label: const Text('Hapus'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isDeleting ? null : _openEditPage,
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKlaimAction() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            // ✅ Tidak lagi pakai _isSubmittingKlaim
            onPressed: _openKlaimDialog,
            icon: const Icon(Icons.assignment_turned_in_outlined),
            label: const Text('Klaim Barang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClaimBlockReason(String reason) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              reason,
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailState() {
    if (_isLoadingDetail) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text(
              'Memuat detail terbaru...',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (_detailError == null || !_hasFallbackData) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gagal memuat detail terbaru. Data sementara tetap ditampilkan.',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _detailError!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          if (_canLoadDetail) ...[
            const SizedBox(height: 6),
            TextButton(onPressed: _loadDetail, child: const Text('Coba lagi')),
          ],
        ],
      ),
    );
  }

  Widget _buildFullErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 42),
            const SizedBox(height: 12),
            Text(
              _detailError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            if (_canLoadDetail) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadDetail,
                child: const Text('Coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  LaporanModel get _currentLaporan {
    return _detail ??
        LaporanModel(
          id: (_currentReportId ?? '').toString(),
          type: _currentReportType,
          namaBarang: widget.title,
          kategoriId: '',
          kategori: widget.category,
          wilayahId: '',
          wilayah: _fallbackWilayah,
          lokasi: _fallbackLokasi,
          deskripsi: widget.description,
          status: widget.reportStatus ?? '',
          tanggal: widget.time,
          imageUrl: widget.imageUrl,
        );
  }

  int? get _currentReportId => _detail?.numericId ?? widget.reportId;

  String get _currentReportType {
    final detailType = _detail?.type.trim() ?? '';
    if (detailType.isNotEmpty) return detailType;

    final widgetType = widget.reportType?.trim() ?? '';
    if (widgetType.isNotEmpty) return widgetType.toLowerCase();

    return widget.status.toLowerCase();
  }

  bool get _canManageHilang {
    return widget.showActionButton &&
        _currentReportId != null &&
        _currentReportType.contains('hilang') &&
        _isManageableReportStatus;
  }

  bool get _canKlaimTemuan {
    return _currentReportId != null &&
        _currentReportType.contains('temuan') &&
        (_detail?.claimable ?? false);
  }

  String? get _claimBlockReason {
    if (!_currentReportType.contains('temuan') || _canKlaimTemuan) return null;

    final reason = _detail?.claimBlockReason?.trim() ?? '';
    return reason.isEmpty ? null : reason;
  }

  bool get _isManageableReportStatus {
    final normalized = (_detail?.status ?? widget.reportStatus ?? '')
        .toLowerCase()
        .trim();

    if (normalized.isEmpty) return true;

    return normalized == 'pending' ||
        normalized == 'submitted' ||
        normalized == 'rejected';
  }

  String get _fallbackWilayah {
    final parts = widget.location.split(' - ');
    return parts.isNotEmpty ? parts.first.trim() : '';
  }

  String get _fallbackLokasi {
    final parts = widget.location.split(' - ');
    if (parts.length <= 1) return widget.location;
    return parts.sublist(1).join(' - ').trim();
  }

  String get _displayTitle {
    final detailTitle = _detail?.namaBarang.trim();
    if (detailTitle != null &&
        detailTitle.isNotEmpty &&
        detailTitle != 'Tanpa nama barang') {
      return detailTitle;
    }
    return widget.title;
  }

  String get _displayCategory =>
      _valueOrFallback(_detail?.kategori, widget.category);

  String get _displayTime =>
      _valueOrFallback(_detail?.tanggalDisplay, widget.time);

  String get _displayTypeBadge =>
      _valueOrFallback(_detail?.jenisBadge, widget.status).toUpperCase();

  String? get _displayReportStatus {
    final value = _valueOrFallback(_detail?.status, widget.reportStatus ?? '');
    return value.isEmpty ? null : value;
  }

  String get _displayDescription =>
      _valueOrFallback(_detail?.deskripsi, widget.description);

  String get _displayImageUrl =>
      _valueOrFallback(_detail?.imageUrl, widget.imageUrl);

  String get _displayLocation {
    if (_detail == null) return widget.location;

    final parts = [
      _detail!.wilayah,
      _detail!.lokasi,
    ].where((v) => v.trim().isNotEmpty && v.trim() != '-').toList();

    if (parts.isEmpty) return widget.location;
    return parts.join(' - ');
  }

  String _valueOrFallback(String? value, String fallback) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty || trimmed == '-') return fallback;
    return trimmed;
  }

  Color _badgeColor(String value) {
    final normalized = value.toLowerCase();
    if (normalized.contains('temuan')) return const Color(0xFF2ECC71);
    if (normalized.contains('hilang')) return const Color(0xFFE74C3C);
    return Colors.grey;
  }

  Widget _buildHeroImage() {
    final imageUrl = _displayImageUrl.trim();
    if (imageUrl.isEmpty) return _buildHeroPlaceholder();

    return SizedBox(
      width: double.infinity,
      height: 250,
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildHeroPlaceholder(isLoading: true);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildHeroPlaceholder();
        },
      ),
    );
  }

  Widget _buildHeroPlaceholder({bool isLoading = false}) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.imageGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.image_outlined, size: 80, color: Colors.white54),
      ),
    );
  }
}

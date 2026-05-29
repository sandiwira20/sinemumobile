import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'core/network/api_client.dart';
import 'edit_profil_page.dart';
import 'features/auth/services/auth_service.dart';
import 'features/profile/models/profile_model.dart';
import 'features/profile/services/profile_service.dart';
import 'login_page.dart';
import 'riwayat_klaim_page.dart';
import 'user_data.dart'; // PANGGIL BRANKASNYA

class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  final ProfileService _profileService = ProfileService();

  bool _isLoading = true;
  String? _errorMessage;
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _profileService.getProfile();
      if (!mounted) return;

      setState(() {
        _profile = profile;
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
        _errorMessage = 'Gagal memuat profile.';
        _isLoading = false;
      });
    }
  }

  Future<void> _openEditProfile() async {
    final profile = _profile;
    if (profile == null) return;

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilPage(initialProfile: profile),
      ),
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui.'),
          backgroundColor: Colors.green,
        ),
      );
      _loadProfile();
    }
  }

  Future<void> _logout() async {
    try {
      await AuthService().logout();
    } catch (_) {}
    await GoogleSignIn().signOut();
    UserData.reset();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  String _apiErrorMessage(ApiException error) {
    return switch (error.statusCode) {
      401 => 'Sesi login sudah berakhir. Silakan login ulang.',
      _ => error.message,
    };
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil Akun',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: profile == null || _isLoading ? null : _openEditProfile,
            child: const Text(
              'EDIT',
              style: TextStyle(
                color: Color(0xFF4A90E2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(profile),
    );
  }

  Widget _buildBody(ProfileModel? profile) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (profile == null) {
      return _buildErrorState(message: 'Profile tidak ditemukan.');
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // --- FOTO PROFIL DARI GOOGLE ---
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: profile.photoUrl.isNotEmpty
                    ? NetworkImage(profile.photoUrl)
                    : null,
                child: profile.photoUrl.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 15),
              // --- NAMA DARI GOOGLE ---
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Pengguna SiNemu',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // --- DATA EMAIL DARI GOOGLE ---
              _buildListTile(
                Icons.badge_outlined,
                'NAMA LENGKAP',
                profile.name,
              ),
              const Divider(height: 1),
              _buildListTile(
                Icons.phone_outlined,
                'NOMOR TELEPON',
                profile.phone.isEmpty ? '-' : profile.phone,
              ),
              const Divider(height: 1),
              _buildListTile(Icons.email_outlined, 'EMAIL', profile.email),
              const Divider(height: 1),
              _buildListTile(
                Icons.alternate_email,
                'USERNAME',
                profile.username.isEmpty ? '-' : profile.username,
              ),
              const Divider(height: 1),
              _buildListTile(
                Icons.location_on_outlined,
                'ALAMAT',
                profile.alamat.isEmpty ? '-' : profile.alamat,
              ),
              const Divider(height: 1),
              _buildActionTile(
                Icons.assignment_turned_in_outlined,
                'RIWAYAT KLAIM',
                'Lihat status klaim barang temuan',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RiwayatKlaimPage(),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- TOMBOL KELUAR ---
              TextButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Keluar Akun',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState({String? message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 42),
            const SizedBox(height: 12),
            Text(
              message ?? _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: _loadProfile, child: const Text('Coba lagi')),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Keluar Akun',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      leading: Icon(icon, color: const Color(0xFF4A90E2), size: 30),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      leading: Icon(icon, color: const Color(0xFF4A90E2), size: 30),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

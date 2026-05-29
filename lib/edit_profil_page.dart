import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'features/profile/models/profile_model.dart';
import 'features/profile/services/profile_service.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key, required this.initialProfile});

  final ProfileModel initialProfile;

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final ProfileService _profileService = ProfileService();
  late final TextEditingController _namaController;
  late final TextEditingController _usernameController;
  late final TextEditingController _teleponController;
  late final TextEditingController _emailController;
  late final TextEditingController _alamatController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.initialProfile.name);
    _usernameController = TextEditingController(
      text: widget.initialProfile.username,
    );
    _teleponController = TextEditingController(
      text: widget.initialProfile.phone,
    );
    _emailController = TextEditingController(text: widget.initialProfile.email);
    _alamatController = TextEditingController(
      text: widget.initialProfile.alamat,
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _teleponController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    final validationMessage = _validateForm();
    if (validationMessage != null) {
      _showSnackBar(validationMessage, isError: true);
      return;
    }

    final updatedProfile = ProfileModel(
      id: widget.initialProfile.id,
      name: _namaController.text.trim(),
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      phone: _teleponController.text.trim(),
      alamat: _alamatController.text.trim(),
      photoUrl: widget.initialProfile.photoUrl,
    );

    setState(() => _isSaving = true);

    try {
      await _profileService.updateProfile(updatedProfile);
      if (!mounted) return;

      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      _showSnackBar(_apiErrorMessage(error), isError: true);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Profil gagal diperbarui. Coba lagi.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _validateForm() {
    if (_namaController.text.trim().isEmpty) {
      return 'Nama wajib diisi.';
    }

    if (_emailController.text.trim().isEmpty) {
      return 'Email wajib diisi.';
    }

    return null;
  }

  String _apiErrorMessage(ApiException error) {
    return switch (error.statusCode) {
      401 => 'Sesi login sudah berakhir. Silakan login ulang.',
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
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: widget.initialProfile.photoUrl.isNotEmpty
                      ? NetworkImage(widget.initialProfile.photoUrl)
                      : null,
                  child: widget.initialProfile.photoUrl.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                'Nama Lengkap',
                Icons.badge_outlined,
                _namaController,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                'Username',
                Icons.alternate_email,
                _usernameController,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                'Nomor Telepon',
                Icons.phone_outlined,
                _teleponController,
                isNumber: true,
              ),
              const SizedBox(height: 15),
              _buildTextField('Email', Icons.email_outlined, _emailController),
              const SizedBox(height: 15),
              _buildTextField(
                'Alamat',
                Icons.location_on_outlined,
                _alamatController,
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        enabled: !_isSaving,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF4A90E2)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

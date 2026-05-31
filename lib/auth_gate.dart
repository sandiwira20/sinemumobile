import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/profile/services/profile_service.dart';
import 'user_data.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.authenticatedPage,
    required this.unauthenticatedPage,
  });

  final Widget authenticatedPage;
  final Widget unauthenticatedPage;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final TokenStorage _tokenStorage = const TokenStorage();
  final ProfileService _profileService = ProfileService();

  bool _isChecking = true;
  bool _isAuthenticated = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      final token = await _tokenStorage.getToken();
      if (token == null || token.trim().isEmpty) {
        if (!mounted) return;

        setState(() {
          _isAuthenticated = false;
          _isChecking = false;
        });
        return;
      }

      await _profileService.getProfile();
      if (!mounted) return;

      setState(() {
        _isAuthenticated = true;
        _isChecking = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      if (error.statusCode == 401) {
        await _clearSession();
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _isChecking = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Gagal mengecek sesi login.';
        _isChecking = false;
      });
    }
  }

  Future<void> _clearSession() async {
    await _tokenStorage.clearToken();
    UserData.reset();
    if (!mounted) return;

    setState(() {
      _isAuthenticated = false;
      _isChecking = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return _buildLoading();
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_isAuthenticated) {
      return widget.authenticatedPage;
    }

    return widget.unauthenticatedPage;
  }

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Mengecek sesi login...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 44),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _checkSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                    ),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _clearSession,
                  child: const Text('Masuk Ulang'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

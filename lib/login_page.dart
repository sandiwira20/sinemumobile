import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'core/config/api_config.dart';
import 'core/network/api_client.dart';
import 'features/auth/services/auth_service.dart';
import 'main.dart';
import 'register_page.dart';
import 'user_data.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isGoogleLoading = false;
  bool _isLoginLoading = false;
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: ApiConfig.googleServerClientId.isEmpty
        ? null
        : ApiConfig.googleServerClientId,
  );
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginDenganGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;

        if (idToken == null || idToken.trim().isEmpty) {
          if (mounted) {
            _showError('Token Google tidak tersedia. Coba lagi.');
          }
          return;
        }

        await _authService.loginWithGoogle(idToken: idToken);

        final googlePhotoUrl = googleUser.photoUrl?.trim();
        if (UserData.fotoUrl.trim().isEmpty &&
            googlePhotoUrl != null &&
            googlePhotoUrl.isNotEmpty) {
          UserData.fotoUrl = googlePhotoUrl;
        }

        if (mounted) {
          final userName = UserData.nama.trim().isEmpty
              ? googleUser.email
              : UserData.nama.trim();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selamat datang, $userName!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      }
    } on ApiException catch (error) {
      if (mounted) {
        _showError(error.message);
      }
    } catch (error) {
      if (mounted) {
        _showError('Login Google gagal. Coba lagi beberapa saat.');
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _loginDenganApi() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      _showError('Login dan password wajib diisi.');
      return;
    }

    setState(() => _isLoginLoading = true);

    try {
      await _authService.login(login: login, password: password);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } on ApiException catch (error) {
      if (mounted) {
        _showError(error.message);
      }
    } catch (_) {
      if (mounted) {
        _showError('Login gagal. Coba lagi beberapa saat.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoginLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logosinemu.png', height: 80),
                const SizedBox(height: 40),
                const Text(
                  'Selamat Datang',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Silakan login untuk melaporkan barang',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                _buildTextField(
                  'Email atau Username',
                  Icons.email_outlined,
                  controller: _loginController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Password',
                  Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _loginDenganApi(),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoginLoading ? null : _loginDenganApi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoginLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'MASUK',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),
                const Text('Atau', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: _isGoogleLoading || _isLoginLoading
                        ? null
                        : _loginDenganGoogle,
                    icon: _isGoogleLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                            height: 24,
                          ),
                    label: Text(
                      _isGoogleLoading ? 'Memproses...' : 'Masuk dengan Google',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun?'),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      ),
                      child: const Text(
                        'Daftar di sini',
                        style: TextStyle(
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon, {
    TextEditingController? controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      enabled: !_isLoginLoading,
      obscureText: isPassword,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF4A90E2)),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; // INI KUNCI UTAMANYA BANG!
import 'main.dart'; // Pastikan ini mengarah ke file yang menampung BerandaPage/MainScreen
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isGoogleLoading = false;

  // Inisialisasi Mesin Google Sign In
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ["email"]);

  // Fungsi untuk memanggil Pop-up Akun Google
  Future<void> _loginDenganGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      // Tunggu user milih akun Gmail-nya
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        // --- SUKSES! ---
        // Nanti emailnya bisa diambil pakai: googleUser.email
        // Namanya bisa diambil pakai: googleUser.displayName

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selamat datang, ${googleUser.displayName}!'),
              backgroundColor: Colors.green,
            ),
          );

          // Langsung lempar ke Beranda
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ), // Sesuaikan dengan class MainScreen/BerandaPage Abang
          );
        }
      } else {
        // User menekan tombol 'Batal' di luar pop-up
        setState(() {
          _isGoogleLoading = false;
        });
      }
    } catch (error) {
      // Jika terjadi error (misal jaringan atau config SHA-1)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal login: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isGoogleLoading = false;
      });
    }
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

                _buildTextField('Email Mahasiswa', Icons.email_outlined),
                const SizedBox(height: 20),
                _buildTextField(
                  'Password',
                  Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 30),

                // TOMBOL MASUK BIASA
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
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

                // TOMBOL GOOGLE
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: _isGoogleLoading ? null : _loginDenganGoogle,
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
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
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
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

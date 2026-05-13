import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_page.dart';
import 'user_data.dart'; // PANGGIL BRANKASNYA

class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {},
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // --- FOTO PROFIL DARI GOOGLE ---
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: UserData.fotoUrl.isNotEmpty
                    ? NetworkImage(UserData.fotoUrl)
                    : null,
                child: UserData.fotoUrl.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 15),
              // --- NAMA DARI GOOGLE ---
              Text(
                UserData.nama,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Mahasiswa Polindra',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // --- DATA EMAIL DARI GOOGLE ---
              _buildListTile(
                Icons.badge_outlined,
                'NAMA LENGKAP',
                UserData.nama,
              ),
              const Divider(height: 1),
              _buildListTile(
                Icons.phone_outlined,
                'NOMOR TELEPON',
                '+62 812 XXXX XXXX',
              ),
              const Divider(height: 1),
              _buildListTile(Icons.email_outlined, 'EMAIL', UserData.email),
              const Divider(height: 1),
              _buildListTile(
                Icons.location_on_outlined,
                'ALAMAT',
                'Indramayu, Jawa Barat',
              ),
              const SizedBox(height: 40),

              // --- TOMBOL KELUAR ---
              TextButton.icon(
                onPressed: () async {
                  await GoogleSignIn().signOut(); // Logout dari Google
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
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
}

import 'package:flutter/material.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // --- 1. BACKGROUND PETA (Bohongan dulu ya Bang) ---
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE0EAFC), // Warna dasar
              image: DecorationImage(
                image: NetworkImage(
                  'https://www.transparenttextures.com/patterns/cubes.png',
                ), // Tekstur jaring-jaring
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          // --- 2. PIN LOKASI BOHONGAN ---
          const Positioned(
            top: 200,
            left: 100,
            child: Icon(Icons.location_on, color: Colors.blue, size: 40),
          ),
          const Positioned(
            top: 350,
            right: 120,
            child: Icon(Icons.location_on, color: Colors.redAccent, size: 40),
          ),

          // --- 3. SEARCH BAR ATAS MELAYANG ---
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    'SiNemu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(Icons.search, color: Colors.grey, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Cari di peta...',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // --- 4. TOMBOL KONTROL KANAN MELAYANG ---
          Positioned(
            top: 90,
            right: 20,
            child: Column(
              children: [
                _buildFloatingBtn(Icons.my_location),
                const SizedBox(height: 10),
                _buildFloatingBtn(Icons.layers_outlined),
              ],
            ),
          ),

          // --- 5. PANEL KECAMATAN BAWAH MELAYANG ---
          Positioned(
            bottom: 20, // Agak diangkat biar gak nabrak navigasi
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PILIH KECAMATAN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Semua', true),
                        const SizedBox(width: 10),
                        _buildFilterChip('Jatibarang', false),
                        const SizedBox(width: 10),
                        _buildFilterChip('Pabean', false),
                        const SizedBox(width: 10),
                        _buildFilterChip('Lohbener', false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET BANTUAN: Tombol Bulat Kanan
  Widget _buildFloatingBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Icon(icon, color: Colors.black54),
    );
  }

  // WIDGET BANTUAN: Kapsul Filter Kecamatan
  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6C9CE1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

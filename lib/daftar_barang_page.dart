import 'package:flutter/material.dart';

class DaftarBarangPage extends StatelessWidget {
  final String kategori; 
  final Color warnaTema;

  const DaftarBarangPage({
    super.key,
    required this.kategori,
    required this.warnaTema,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Semua Barang $kategori', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: warnaTema,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 6, // Contoh nampilin 6 barang
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: warnaTema.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.inventory_2_outlined, color: warnaTema, size: 30),
              ),
              title: Text(
                'Contoh Barang $kategori ${index + 1}', 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
              ),
              subtitle: const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Lokasi: Gedung Polindra\n2 Jam yang lalu'),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                // Nanti kita buat pindah ke halaman Detail Barang
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Klik barang ke-${index + 1}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
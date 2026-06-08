import 'package:flutter/material.dart';

class LaporTemuanPage extends StatefulWidget {
  const LaporTemuanPage({super.key});

  @override
  State<LaporTemuanPage> createState() => _LaporTemuanPageState();
}

class _LaporTemuanPageState extends State<LaporTemuanPage> {
  final _formKey = GlobalKey<FormState>();

  // Variabel untuk Dropdown

  String? _selectedWilayah;

  String? _selectedKategori;

  // CONTROLLER UNTUK TANGGAL DAN JAM BIAR BISA NAMPILIN HASIL PILIHAN

  final TextEditingController _tanggalController = TextEditingController();

  final TextEditingController _jamController = TextEditingController();

  // Data Dropdown

  final List<String> _listWilayah = [
    'Kecamatan Anjatan',

    'Kecamatan Arahan',

    'Kecamatan Balongan',

    'Kecamatan Bangodua',

    'Kecamatan Bongas',

    'Kecamatan Cantigi',

    'Kecamatan Cikedung',

    'Kecamatan Gabuswetan',

    'Kecamatan Gantar',

    'Kecamatan Haurgeulis',

    'Kecamatan Indramayu',

    'Kecamatan Jatibarang',

    'Kecamatan Juntinyuat',

    'Kecamatan Kandanghaur',

    'Kecamatan Karangampel',

    'Kecamatan Kedokan Bunder',

    'Kecamatan Kertasemaya',

    'Kecamatan Krangkeng',

    'Kecamatan Kroya',

    'Kecamatan Lelea',

    'Kecamatan Lohbener',

    'Kecamatan Losarang',

    'Kecamatan Pasekan',

    'Kecamatan Patrol',

    'Kecamatan Sindang',

    'Kecamatan Sliyeg',

    'Kecamatan Sukagumiwang',

    'Kecamatan Sukra',

    'Kecamatan Terisi',

    'Kecamatan Tukdana',

    'Kecamatan Widasari',
  ];

  final List<String> _listKategori = [
    'Aksesoris',

    'Buku atau Alat Tulis',

    'Dokumen',

    'Dompet',

    'Elektronik',

    'Kartu Identitas',

    'Kendaraan',

    'Kunci',

    'Mainan',

    'Pakaian',

    'Perhiasan',

    'Perlengkapan Pribadi',

    'Uang',

    'Lainnya',
  ];

  // --- FUNGSI MUNCULIN KALENDER ---

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,

      initialDate: DateTime.now(), // Mulai dari hari ini

      firstDate: DateTime(2000), // Tahun paling lama

      lastDate: DateTime(2100), // Tahun paling baru

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E88E5), // Warna header kalender biru SiNemu
            ),
          ),

          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Format jadi dd/mm/yyyy

        String hari = picked.day.toString().padLeft(2, '0');

        String bulan = picked.month.toString().padLeft(2, '0');

        String tahun = picked.year.toString();

        _tanggalController.text = "$hari/$bulan/$tahun";
      });
    }
  }

  // --- FUNGSI MUNCULIN JAM ---

  Future<void> _pilihJam(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,

      initialTime: TimeOfDay.now(),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E88E5), // Warna jam biru SiNemu
            ),
          ),

          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Format jadi HH:MM

        String jam = picked.hour.toString().padLeft(2, '0');

        String menit = picked.minute.toString().padLeft(2, '0');

        _jamController.text = "$jam:$menit";
      });
    }
  }

  // Bersihin memori pas halaman ditutup

  @override
  void dispose() {
    _tanggalController.dispose();

    _jamController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        title: const Text(
          'Lapor Barang Temuan',

          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),

        backgroundColor: Colors.white,

        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Container(
                  padding: const EdgeInsets.all(15),

                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,

                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: const Text(
                    "Laporkan barang temuan agar pemilik dapat dihubungi dan proses pengambilan berjalan tertib.",

                    style: TextStyle(color: Colors.blue, fontSize: 13),
                  ),
                ),

                const SizedBox(height: 25),

                _buildInputLabel("Nama Barang", isWajib: true),

                _buildTextField("Contoh: HP Android warna hitam"),

                const SizedBox(height: 15),

                _buildInputLabel("Wilayah Ditemukan", isWajib: true),

                _buildDropdown(
                  hint: "Pilih kecamatan",

                  items: _listWilayah,

                  selectedValue: _selectedWilayah,

                  onChanged: (value) {
                    setState(() {
                      _selectedWilayah = value;
                    });
                  },
                ),

                const Text(
                  "Barang temuan akan diteruskan ke pengelola barang wilayah ini.",

                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),

                const SizedBox(height: 15),

                _buildInputLabel("Kategori"),

                _buildDropdown(
                  hint: "Pilih kategori",

                  items: _listKategori,

                  selectedValue: _selectedKategori,

                  onChanged: (value) {
                    setState(() {
                      _selectedKategori = value;
                    });
                  },
                ),

                const SizedBox(height: 15),

                _buildInputLabel("Warna Dominan"),

                _buildTextField("Contoh: Hitam"),

                const SizedBox(height: 15),

                _buildInputLabel("Merek / Brand"),

                _buildTextField("Contoh: Samsung, Casio"),

                const SizedBox(height: 15),

                _buildInputLabel("Nomor Seri / Kode Unik"),

                _buildTextField("Contoh: IMEI atau nomor seri"),

                const SizedBox(height: 15),

                _buildInputLabel("Lokasi Ditemukan", isWajib: true),

                _buildTextField("Contoh: Lobi Gedung A"),

                const SizedBox(height: 15),

                // --- TANGGAL YANG BISA DIKLIK MUNCUL KALENDER ---
                _buildInputLabel("Tanggal Ditemukan", isWajib: true),

                _buildClickableField(
                  hint: "dd/mm/tttt",

                  icon: Icons.calendar_today,

                  controller: _tanggalController,

                  onTap: () => _pilihTanggal(context),
                ),

                const SizedBox(height: 15),

                // --- JAM YANG BISA DIKLIK MUNCUL JAM DIGITAL ---
                _buildInputLabel("Perkiraan Jam Ditemukan"),

                _buildClickableField(
                  hint: "--:--",

                  icon: Icons.access_time,

                  controller: _jamController,

                  onTap: () => _pilihJam(context),
                ),

                const SizedBox(height: 15),

                _buildInputLabel("Detail Lokasi Ditemukan"),

                _buildTextArea(
                  "Contoh: Ditemukan di dekat pintu barat, sebelah mesin absensi.",
                ),

                const SizedBox(height: 15),

                _buildInputLabel("Deskripsi", isWajib: true),

                _buildTextArea(
                  "Jelaskan ciri barang dan kondisi saat ditemukan.",
                ),

                const SizedBox(height: 15),

                _buildInputLabel("Ciri Unik Barang"),

                _buildTextArea(
                  "Contoh: Ada stiker, goresan tertentu, atau aksesori khusus.",
                ),

                const SizedBox(height: 15),

                _buildInputLabel("Nama Penemu"),

                _buildTextField("Sandi Wira"),

                const SizedBox(height: 15),

                _buildInputLabel("No. WA Penemu", isWajib: true),

                _buildTextField("Contoh: 081234567890"),

                const SizedBox(height: 15),

                _buildInputLabel("Foto Barang (Opsional)"),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,

                    vertical: 12,
                  ),

                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),

                    borderRadius: BorderRadius.circular(10),

                    color: Colors.white,
                  ),

                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,

                          foregroundColor: Colors.black,

                          elevation: 0,
                        ),

                        child: const Text("Pilih File"),
                      ),

                      const SizedBox(width: 10),

                      const Text(
                        "Tidak ada file yang dipilih",

                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Format: JPG, JPEG, PNG, WEBP. Maksimal 3MB.",

                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,

                  height: 50,

                  child: ElevatedButton(
                    onPressed: () {},

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    child: const Text(
                      "Kirim Laporan",

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 16,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET PEMBANTU ---

  Widget _buildInputLabel(String text, {bool isWajib = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),

      child: RichText(
        text: TextSpan(
          text: text,

          style: const TextStyle(
            color: Colors.black87,

            fontWeight: FontWeight.bold,

            fontSize: 14,
          ),

          children: [
            if (isWajib)
              const TextSpan(
                text: " *",

                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {IconData? icon}) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),

        filled: true,

        fillColor: Colors.white,

        suffixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,

          vertical: 15,
        ),

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),

          borderRadius: BorderRadius.circular(10),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF1E88E5)),

          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // WIDGET KHUSUS BIAR FIELD TANGGAL & JAM BISA DIKLIK TAPI GAK BISA DIKETIK MANUAL

  Widget _buildClickableField({
    required String hint,

    required IconData icon,

    required TextEditingController controller,

    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,

      readOnly: true, // Kunci keyboard biar gak muncul

      onTap: onTap, // Jalankan kalender/jam saat diklik

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),

        filled: true,

        fillColor: Colors.white,

        suffixIcon: Icon(icon, color: Colors.black54),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,

          vertical: 15,
        ),

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),

          borderRadius: BorderRadius.circular(10),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF1E88E5)),

          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildTextArea(String hint) {
    return TextFormField(
      maxLines: 4,

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),

        filled: true,

        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,

          vertical: 15,
        ),

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),

          borderRadius: BorderRadius.circular(10),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF1E88E5)),

          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,

    required List<String> items,

    required String? selectedValue,

    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),

      decoration: BoxDecoration(
        color: Colors.white,

        border: Border.all(color: Colors.grey.shade300),

        borderRadius: BorderRadius.circular(10),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,

          hint: Text(
            hint,

            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),

          value: selectedValue,

          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,

              child: Text(value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),

          onChanged: onChanged,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final MapController _mapController = MapController();
  String kecamatanDipilih = 'Semua';
  LatLng? _lokasiSaya;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  final List<Map<String, dynamic>> kecamatan = [
    {"nama": "Haurgeulis",     "lat": -6.2897, "lng": 107.9856},
    {"nama": "Gantar",         "lat": -6.4078, "lng": 108.0234},
    {"nama": "Kroya",          "lat": -6.3712, "lng": 108.0812},
    {"nama": "Gabuswetan",     "lat": -6.4234, "lng": 108.1523},
    {"nama": "Cikedung",       "lat": -6.5012, "lng": 108.1734},
    {"nama": "Terisi",         "lat": -6.5234, "lng": 108.2156},
    {"nama": "Lelea",          "lat": -6.4656, "lng": 108.2434},
    {"nama": "Bangodua",       "lat": -6.5023, "lng": 108.2812},
    {"nama": "Tukdana",        "lat": -6.5312, "lng": 108.3034},
    {"nama": "Widasari",       "lat": -6.4734, "lng": 108.2956},
    {"nama": "Kertasemaya",    "lat": -6.4656, "lng": 108.3512},
    {"nama": "Sukagumiwang",   "lat": -6.4823, "lng": 108.3812},
    {"nama": "Krangkeng",      "lat": -6.4234, "lng": 108.4756},
    {"nama": "Karangampel",    "lat": -6.3923, "lng": 108.4623},
    {"nama": "Kedokan Bunder", "lat": -6.4156, "lng": 108.4312},
    {"nama": "Juntinyuat",     "lat": -6.3512, "lng": 108.4234},
    {"nama": "Sliyeg",         "lat": -6.4712, "lng": 108.2756},
    {"nama": "Jatibarang",     "lat": -6.4758, "lng": 108.3104},
    {"nama": "Balongan",       "lat": -6.2756, "lng": 108.3712},
    {"nama": "Indramayu",      "lat": -6.3265, "lng": 108.3209},
    {"nama": "Sindang",        "lat": -6.3634, "lng": 108.3512},
    {"nama": "Cantigi",        "lat": -6.2623, "lng": 108.2956},
    {"nama": "Pasekan",        "lat": -6.2934, "lng": 108.3423},
    {"nama": "Lohbener",       "lat": -6.3812, "lng": 108.2634},
    {"nama": "Arahan",         "lat": -6.3712, "lng": 108.3956},
    {"nama": "Losarang",       "lat": -6.2523, "lng": 108.2312},
    {"nama": "Kandanghaur",    "lat": -6.2156, "lng": 108.1123},
    {"nama": "Bongas",         "lat": -6.2034, "lng": 108.0634},
    {"nama": "Anjatan",        "lat": -6.2423, "lng": 108.1423},
    {"nama": "Sukra",          "lat": -6.1923, "lng": 108.0823},
    {"nama": "Patrol",         "lat": -6.1812, "lng": 108.0423},
  ];

  List<Map<String, dynamic>> get kecamatanFiltered {
    if (kecamatanDipilih == 'Semua') return kecamatan;
    return kecamatan.where((k) => k['nama'] == kecamatanDipilih).toList();
  }

  List<String> get daftarNamaKecamatan {
    final names = kecamatan.map((k) => k['nama'] as String).toList();
    names.sort();
    return ['Semua', ...names];
  }

  @override
  void initState() {
    super.initState();
    _ambilLokasi();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _ambilLokasi() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GPS tidak aktif, aktifkan dulu!')),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin lokasi ditolak!')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Izin lokasi ditolak permanen, buka Settings!')),
        );
      }
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _lokasiSaya = LatLng(position.latitude, position.longitude);
    });

    _mapController.move(_lokasiSaya!, 13);
  }

  Future<void> _cariLokasi(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final kecamatanMatch = kecamatan
          .where((k) => (k['nama'] as String)
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();

      if (kecamatanMatch.isNotEmpty) {
        setState(() {
          _searchResults = kecamatanMatch
              .map((k) => {
                    'display_name': 'Kec. ${k['nama']}, Indramayu',
                    'lat': k['lat'].toString(),
                    'lon': k['lng'].toString(),
                    'isKecamatan': true,
                  })
              .toList();
          _isSearching = false;
        });
      } else {
        final response = await Dio().get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'q': '$query, Kabupaten Indramayu, Jawa Barat, Indonesia',
            'format': 'json',
            'limit': 5,
            'countrycodes': 'id',
            'bounded': '1',
            'viewbox': '107.85,-6.60,108.60,-6.10',
          },
          options: Options(headers: {'User-Agent': 'SiNemuApp/1.0'}),
        );

        setState(() {
          _searchResults = response.data;
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // --- 1. PETA ---
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(-6.3265, 108.3209),
              initialZoom: 10,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.sinemu.app',
              ),
              MarkerLayer(
                markers: [
                  if (_lokasiSaya != null)
                    Marker(
                      point: _lokasiSaya!,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.my_location,
                            color: Colors.blue, size: 30),
                      ),
                    ),
                  ...kecamatanFiltered.map(
                    (kec) => Marker(
                      point: LatLng(kec['lat'], kec['lng']),
                      width: 90,
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => kecamatanDipilih = kec['nama']);
                          _mapController.move(
                              LatLng(kec['lat'], kec['lng']), 14);
                        },
                        child: Column(
                          children: [
                            const Icon(Icons.location_pin,
                                color: Colors.green, size: 30),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 3)
                                ],
                              ),
                              child: Text(kec['nama'],
                                  style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // --- 2. SEARCH BAR + HASIL ---
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Search Bar
                Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ✅ LOGO dari assets
                      Image.asset(
                        'assets/images/logosinemu.png',
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      // Search field
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _cariLokasi,
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Cari kecamatan / tempat...',
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 13),
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.grey, size: 18),
                              border: InputBorder.none,
                              isDense: true,
                              // ✅ FIX: padding biar teks tidak kebawah
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 9, horizontal: 4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tombol clear / avatar
                      _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () => setState(() {
                                _searchController.clear();
                                _searchResults = [];
                              }),
                              child: const Icon(Icons.close,
                                  color: Colors.grey, size: 20),
                            )
                          : const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 18),
                            ),
                    ],
                  ),
                ),

                // Hasil pencarian
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 50),
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        final isKecamatan = result['isKecamatan'] == true;
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            isKecamatan
                                ? Icons.location_city
                                : Icons.location_on,
                            color: isKecamatan
                                ? Colors.green
                                : const Color(0xFF4A90E2),
                            size: 20,
                          ),
                          title: Text(
                            result['display_name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () {
                            final lat = double.parse(result['lat']);
                            final lon = double.parse(result['lon']);
                            _mapController.move(LatLng(lat, lon), 14);
                            setState(() {
                              _searchResults = [];
                              _searchController.clear();
                            });
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),

                // Loading
                if (_isSearching)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Mencari...', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // --- 3. TOMBOL KONTROL KANAN ---
          // ✅ FIX: top dinaikkan agar tidak tertimpa search bar
          Positioned(
            top: 86,
            right: 16,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _ambilLokasi,
                  child: _buildFloatingBtn(Icons.my_location),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  ),
                  child: _buildFloatingBtn(Icons.add),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  ),
                  child: _buildFloatingBtn(Icons.remove),
                ),
              ],
            ),
          ),

          // --- 4. PANEL FILTER KECAMATAN BAWAH ---
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PILIH KECAMATAN',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black87),
                      ),
                      Text(
                        '${kecamatan.length} kecamatan',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: daftarNamaKecamatan
                          .map((nama) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => kecamatanDipilih = nama);
                                    if (nama != 'Semua') {
                                      final kec = kecamatan.firstWhere(
                                          (k) => k['nama'] == nama,
                                          orElse: () => {});
                                      if (kec.isNotEmpty) {
                                        _mapController.move(
                                            LatLng(kec['lat'], kec['lng']),
                                            13);
                                      }
                                    } else {
                                      _mapController.move(
                                          const LatLng(-6.3265, 108.3209),
                                          10);
                                    }
                                  },
                                  child: _buildFilterChip(
                                      nama, kecamatanDipilih == nama),
                                ),
                              ))
                          .toList(),
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

  Widget _buildFloatingBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15), blurRadius: 5),
        ],
      ),
      child: Icon(icon, color: Colors.black54, size: 20),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
          fontSize: 13,
        ),
      ),
    );
  }
}
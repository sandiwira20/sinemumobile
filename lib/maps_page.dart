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
  List<LatLng> _rutePoints = [];
  Map<String, dynamic>? _kecamatanTerpilih;

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingRute = false;

  // =====================
  // DATA 31 KECAMATAN INDRAMAYU (Koordinat Akurat)
  // =====================
  final List<Map<String, dynamic>> kecamatan = [
    {"nama": "Anjatan", "lat": -6.3475, "lng": 107.9542},
    {"nama": "Arahan", "lat": -6.2944, "lng": 108.2045},
    {"nama": "Balongan", "lat": -6.3601, "lng": 108.3687},
    {"nama": "Bangodua", "lat": -6.5167, "lng": 108.2500},
    {"nama": "Bongas", "lat": -6.3881, "lng": 107.9904},
    {"nama": "Cantigi", "lat": -6.2625, "lng": 108.2433},
    {"nama": "Cikedung", "lat": -6.5683, "lng": 108.1306},
    {"nama": "Gabuswetan", "lat": -6.4385, "lng": 108.0645},
    {"nama": "Gantar", "lat": -6.5592, "lng": 107.9427},
    {"nama": "Haurgeulis", "lat": -6.4578, "lng": 107.9442},
    {"nama": "Indramayu", "lat": -6.3264, "lng": 108.3229},
    {"nama": "Jatibarang", "lat": -6.4716, "lng": 108.3071},
    {"nama": "Juntinyuat", "lat": -6.4024, "lng": 108.4173},
    {"nama": "Kandanghaur", "lat": -6.3236, "lng": 108.1064},
    {"nama": "Karangampel", "lat": -6.4526, "lng": 108.4519},
    {"nama": "Kedokan Bunder", "lat": -6.4862, "lng": 108.4061},
    {"nama": "Kertasemaya", "lat": -6.5297, "lng": 108.3586},
    {"nama": "Krangkeng", "lat": -6.5050, "lng": 108.4550},
    {"nama": "Kroya", "lat": -6.5074, "lng": 108.0538},
    {"nama": "Lelea", "lat": -6.4950, "lng": 108.1965},
    {"nama": "Lohbener", "lat": -6.3983, "lng": 108.2581},
    {"nama": "Losarang", "lat": -6.3847, "lng": 108.1697},
    {"nama": "Pasekan", "lat": -6.2570, "lng": 108.2721},
    {"nama": "Patrol", "lat": -6.2942, "lng": 107.9744},
    {"nama": "Sindang", "lat": -6.3298, "lng": 108.2933},
    {"nama": "Sliyeg", "lat": -6.4521, "lng": 108.3541},
    {"nama": "Sukagumiwang", "lat": -6.5595, "lng": 108.3683},
    {"nama": "Sukra", "lat": -6.2731, "lng": 107.9255},
    {"nama": "Terisi", "lat": -6.5414, "lng": 108.1972},
    {"nama": "Tukdana", "lat": -6.5701, "lng": 108.2612},
    {"nama": "Widasari", "lat": -6.4533, "lng": 108.2731},
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

  // =====================
  // FUNGSI LOKASI GPS
  // =====================
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
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _lokasiSaya = LatLng(position.latitude, position.longitude);
    });

    _mapController.move(_lokasiSaya!, 12);
  }

  // =====================
  // FUNGSI RUTE KE KECAMATAN
  // =====================
  Future<void> _ambilRute(LatLng tujuan) async {
    if (_lokasiSaya == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aktifkan GPS dulu untuk melihat rute!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoadingRute = true);

    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${_lokasiSaya!.longitude},${_lokasiSaya!.latitude};'
          '${tujuan.longitude},${tujuan.latitude}'
          '?overview=full&geometries=geojson';

      final response = await Dio().get(url);
      final coords =
          response.data['routes'][0]['geometry']['coordinates'] as List;

      setState(() {
        _rutePoints = coords
            .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
            .toList();
        _isLoadingRute = false;
      });

      // Fit map to show full route
      if (_rutePoints.isNotEmpty) {
        _mapController.move(
          LatLng(
            (_lokasiSaya!.latitude + tujuan.latitude) / 2,
            (_lokasiSaya!.longitude + tujuan.longitude) / 2,
          ),
          11,
        );
      }
    } catch (e) {
      setState(() => _isLoadingRute = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat rute. Coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // =====================
  // FUNGSI CARI LOKASI
  // =====================
  Future<void> _cariLokasi(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final kecamatanMatch = kecamatan
          .where(
            (k) => (k['nama'] as String).toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();

      if (kecamatanMatch.isNotEmpty) {
        setState(() {
          _searchResults = kecamatanMatch
              .map(
                (k) => {
                  'display_name': 'Kec. ${k['nama']}, Indramayu',
                  'lat': k['lat'].toString(),
                  'lon': k['lng'].toString(),
                  'isKecamatan': true,
                  'namaKecamatan': k['nama'],
                },
              )
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

  // =====================
  // TAMPILKAN BOTTOM SHEET DETAIL KECAMATAN
  // =====================
  void _tampilkanDetailKecamatan(Map<String, dynamic> kec) {
    setState(() => _kecamatanTerpilih = kec);
    final latLng = LatLng(kec['lat'], kec['lng']);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_city,
                      color: Colors.green,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kecamatan ${kec['nama']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Kabupaten Indramayu',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Tombol Tampilkan Rute
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoadingRute
                      ? null
                      : () {
                          Navigator.pop(context);
                          _ambilRute(latLng);
                        },
                  icon: _isLoadingRute
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.directions),
                  label: Text(
                    _isLoadingRute ? 'Memuat rute...' : 'Tampilkan Rute',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Tombol Hapus Rute
              if (_rutePoints.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _rutePoints = []);
                    },
                    icon: const Icon(Icons.clear, color: Colors.red),
                    label: const Text(
                      'Hapus Rute',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // =====================
  // BUILD
  // =====================
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

              // Rute
              if (_rutePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _rutePoints,
                      color: const Color(0xFF4A90E2),
                      strokeWidth: 5,
                    ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  // Marker lokasi saya
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
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    ),

                  // Marker kecamatan
                  ...kecamatanFiltered.map(
                    (kec) => Marker(
                      point: LatLng(kec['lat'], kec['lng']),
                      width: 90,
                      height: 60,
                      child: GestureDetector(
                        onTap: () => _tampilkanDetailKecamatan(kec),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_pin,
                              color: _kecamatanTerpilih?['nama'] == kec['nama']
                                  ? Colors.blue
                                  : Colors.green,
                              size: 32,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: Text(
                                kec['nama'],
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

          // --- 2. SEARCH BAR ---
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
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
                      Image.asset(
                        'assets/images/logosinemu.png',
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
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
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                                size: 18,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 9,
                                horizontal: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () => setState(() {
                                _searchController.clear();
                                _searchResults = [];
                              }),
                              child: const Icon(
                                Icons.close,
                                color: Colors.grey,
                                size: 20,
                              ),
                            )
                          : const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 18,
                              ),
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
                          blurRadius: 10,
                        ),
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

                            // Kalau hasil pencarian adalah kecamatan, tampilkan detail
                            if (isKecamatan) {
                              final nama = result['namaKecamatan'] as String;
                              final kec = kecamatan.firstWhere(
                                (k) => k['nama'] == nama,
                                orElse: () => {},
                              );
                              if (kec.isNotEmpty) {
                                _tampilkanDetailKecamatan(kec);
                              }
                            }
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
                // Tombol hapus rute
                if (_rutePoints.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _rutePoints = []),
                    child: _buildFloatingBtn(Icons.clear, color: Colors.red),
                  ),
                ],
              ],
            ),
          ),

          // Loading rute indicator
          if (_isLoadingRute)
            Positioned(
              top: 86,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Memuat rute...', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
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
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${kecamatan.length} kecamatan',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: daftarNamaKecamatan
                          .map(
                            (nama) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => kecamatanDipilih = nama);
                                  if (nama != 'Semua') {
                                    final kec = kecamatan.firstWhere(
                                      (k) => k['nama'] == nama,
                                      orElse: () => {},
                                    );
                                    if (kec.isNotEmpty) {
                                      _mapController.move(
                                        LatLng(kec['lat'], kec['lng']),
                                        13,
                                      );
                                    }
                                  } else {
                                    _mapController.move(
                                      const LatLng(-6.3265, 108.3209),
                                      10,
                                    );
                                  }
                                },
                                child: _buildFilterChip(
                                  nama,
                                  kecamatanDipilih == nama,
                                ),
                              ),
                            ),
                          )
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

  Widget _buildFloatingBtn(IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 5),
        ],
      ),
      child: Icon(icon, color: color ?? Colors.black54, size: 20),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4A90E2) : Colors.white,
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

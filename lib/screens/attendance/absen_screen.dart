import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Mengasumsikan import sesuai dengan struktur folder kamu:
// import '../../core/constants/app_colors.dart';
// import '../../core/utils/haversine_util.dart';
// import '../../providers/attendance_provider.dart';
// import '../../providers/office_provider.dart';
// import '../widgets/geo_radius_map.dart'; // Jika menggunakan custom widget map

class AbsenScreen extends StatefulWidget {
  const AbsenScreen({Key? key}) : super(key: key);

  @override
  State<AbsenScreen> createState() => _AbsenScreenState();
}

class _AbsenScreenState extends State<AbsenScreen> {
  // Simulasi state lokasi user saat ini (Nantinya didapat dari LocationService/Provider)
  LatLng _currentLocation = const LatLng(-6.9147, 107.6098); 
  final LatLng _officeLocation = const LatLng(-6.9140, 107.6090);
  final double _officeRadius = 50.0; // dalam meter

  bool _isLoading = false;

  // Fungsi untuk refresh lokasi
  Future<void> _refreshLocation() async {
    setState(() => _isLoading = true);
    // TODO: Panggil LocationService.getCurrentPosition() di sini
    await Future.delayed(const Duration(seconds: 1)); // Simulasi delay
    setState(() => _isLoading = false);
  }

  // Fungsi konfirmasi absen
  void _submitAttendance() {
    // TODO: Panggil context.read<AttendanceProvider>().checkIn(...)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Absen berhasil disimpan!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Hitung jarak menggunakan HaversineUtil (Simulasi fungsi dari utils kamu)
    // double distance = HaversineUtil.calculateDistance(_currentLocation, _officeLocation);
    double distance = 32.0; // Simulasi hasil jarak seperti di gambar
    bool isWithinRadius = distance <= _officeRadius;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Absen Masuk',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Google Maps / GeoRadiusMap di background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.45, // Sisakan ruang untuk bottom sheet
            // Ganti dengan widget GeoRadiusMap milikmu jika ada
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _officeLocation,
                zoom: 17,
              ),
              zoomControlsEnabled: false,
              myLocationEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('office'),
                  position: _officeLocation,
                  infoWindow: const InfoWindow(title: 'KANTOR'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
                Marker(
                  markerId: const MarkerId('user'),
                  position: _currentLocation,
                  infoWindow: const InfoWindow(title: 'Posisi Kamu'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                ),
              },
              circles: {
                Circle(
                  circleId: const CircleId('office_radius'),
                  center: _officeLocation,
                  radius: _officeRadius,
                  fillColor: Colors.blue.withOpacity(0.2),
                  strokeColor: Colors.blue,
                  strokeWidth: 1,
                ),
              },
            ),
          ),

          // 2. Floating Label Radius di atas Map
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gps_fixed, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Radius: ${_officeRadius.toInt()} m',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Sheet Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.52,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle Indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Judul & Jarak
                  const Text(
                    'Posisi Kamu',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.near_me_outlined,
                        size: 20,
                        color: isWithinRadius ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${distance.toInt()} meter dari kantor',
                        style: TextStyle(
                          fontSize: 16,
                          color: isWithinRadius ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status Box (Hijau jika di dalam radius, Merah jika di luar)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isWithinRadius ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isWithinRadius ? Colors.green.shade200 : Colors.red.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isWithinRadius ? Icons.check_circle : Icons.cancel,
                          color: isWithinRadius ? Colors.green.shade700 : Colors.red.shade700,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isWithinRadius ? 'Dalam Radius' : 'Di Luar Radius',
                                style: TextStyle(
                                  color: isWithinRadius ? Colors.green.shade800 : Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isWithinRadius 
                                  ? 'Kamu bisa melakukan absen sekarang.' 
                                  : 'Mendekatlah ke area kantor untuk absen.',
                                style: TextStyle(
                                  color: isWithinRadius ? Colors.green.shade700 : Colors.red.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Koordinat & Tombol Refresh
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.my_location, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Lat: ${_currentLocation.latitude.toStringAsFixed(4)} • Long: ${_currentLocation.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(color: Colors.black87, fontSize: 13),
                          ),
                        ),
                        if (_isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          InkWell(
                            onTap: _refreshLocation,
                            child: const Text(
                              'Refresh',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Tombol Konfirmasi
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isWithinRadius ? _submitAttendance : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.fingerprint, color: Colors.white),
                      label: const Text(
                        'Konfirmasi Absen Masuk',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tombol Batal
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}
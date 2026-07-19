import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';   
import '../../core/routes/app_routes.dart'; 
import '../../providers/office_provider.dart'; 

class AbsenScreen extends StatefulWidget {
  const AbsenScreen({Key? key}) : super(key: key);

  @override
  State<AbsenScreen> createState() => _AbsenScreenState();
}

class _AbsenScreenState extends State<AbsenScreen> {
  final MapController _mapController = MapController();

  LatLng _officeLocation = const LatLng(-6.2088, 106.8456); 
  double _officeRadius = 50.0;
  String _officeName = 'Kantor';

  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  String? _errorMessage;
  bool _initializedMapCenter = false;
  bool _isSubmitting = false; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final officeProvider = context.read<OfficeProvider>();
      await officeProvider.loadOffice();
      _applyOfficeData();
      _refreshLocation();
    });
  }

  void _applyOfficeData() {
    final office = context.read<OfficeProvider>().office;
    if (office != null) {
      setState(() {
        _officeLocation = LatLng(office.latitude, office.longitude);
        _officeRadius = office.radius;
        _officeName = office.nama;
      });
      if (!_initializedMapCenter) {
        _mapController.move(_officeLocation, 16);
      }
    }
  }

  double get _distance {
    if (_currentLocation == null) return double.infinity;
    return Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      _officeLocation.latitude,
      _officeLocation.longitude,
    );
  }

  bool get _isWithinRadius => _distance <= _officeRadius;

  Future<void> _refreshLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;

      if (!serviceEnabled) {
        throw Exception('Aktifkan GPS terlebih dahulu');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (!mounted) return;

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Izin lokasi ditolak permanen, aktifkan lewat Settings',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final userLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = userLatLng;
        _initializedMapCenter = true;
      });

      _mapController.move(userLatLng, 16);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _handleBackOrCancel() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  // --- FUNGSI UPDATE DATABASE ---
  Future<void> _submitAttendance() async {
    if (_isSubmitting) return; 
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        throw Exception('User tidak ditemukan. Pastikan Anda sudah login.');
      }

      // Pastikan string 'statusHariIni' identik persis dengan yang ada di Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'statusHariIni': 'Hadir', // Merubah field statusHariIni di luar array
        'riwayatAbsensi': FieldValue.arrayUnion([
          {
            'waktu': Timestamp.now(),
            'statusHariIni': 'Hadir', // Memasukkan status kehadiran ke dalam array riwayat
            'lokasi': '${_currentLocation!.latitude}, ${_currentLocation!.longitude}',
          }
        ])
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Absen masuk berhasil di posisi $_officeName!'),
          backgroundColor: Colors.green,
        ),
      );
      _handleBackOrCancel();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal melakukan absen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final officeLoading = context.watch<OfficeProvider>().isLoading;
    
    final distance = _distance;
    final isWithinRadius = _isWithinRadius;
    final hasLocation = _currentLocation != null;

    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackOrCancel(); 
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _handleBackOrCancel,
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
        body: officeLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: MediaQuery.of(context).size.height * 0.45,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _officeLocation,
                          initialZoom: 16,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.tugasBesar',
                          ),
                          CircleLayer(
                            circles: [
                              CircleMarker(
                                point: _officeLocation,
                                radius: _officeRadius,
                                useRadiusInMeter: true,
                                color: Colors.blue.withOpacity(0.2),
                                borderColor: Colors.blue,
                                borderStrokeWidth: 1.5,
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _officeLocation,
                                width: 45,
                                height: 45,
                                child: const Icon(
                                  Icons.location_city,
                                  color: Colors.red,
                                  size: 36,
                                ),
                              ),
                              if (hasLocation)
                                Marker(
                                  point: _currentLocation!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.person_pin_circle,
                                    color: Colors.green,
                                    size: 38,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      if (_isLoadingLocation)
                        Container(
                          color: Colors.black26,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),

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
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const SizedBox(height: 20),

                        Text(
                          _officeName, 
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Posisi Kamu Sekarang',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),

                        if (_errorMessage != null)
                          Row(
                            children: [
                              Icon(Icons.error_outline, size: 20, color: Colors.red.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(fontSize: 14, color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          )
                        else if (!hasLocation)
                          Row(
                            children: const [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Mencari lokasi kamu...'),
                            ],
                          )
                        else
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

                        if (hasLocation)
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
                                            : 'Mendekatlah ke area area kantor untuk absen.',
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
                                  hasLocation
                                      ? 'Lat: ${_currentLocation!.latitude.toStringAsFixed(5)} • Long: ${_currentLocation!.longitude.toStringAsFixed(5)}'
                                      : 'Lokasi belum tersedia',
                                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                                ),
                              ),
                              if (_isLoadingLocation)
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
                                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Spacer(),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: (hasLocation && isWithinRadius && !_isLoadingLocation && !_isSubmitting)
                                ? _submitAttendance
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            icon: _isSubmitting 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.fingerprint, color: Colors.white),
                            label: Text(
                              _isSubmitting ? 'Memproses...' : 'Konfirmasi Absen Masuk',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: _isSubmitting ? null : _handleBackOrCancel,
                            child: const Text(
                              'Batal',
                              style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
} 
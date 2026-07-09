import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/office_provider.dart';

class OfficeSettingScreen extends StatefulWidget {
  const OfficeSettingScreen({super.key});

  @override
  State<OfficeSettingScreen> createState() => _OfficeSettingScreenState();
}

class _OfficeSettingScreenState extends State<OfficeSettingScreen> {
  final _namaController = TextEditingController();
  final MapController _mapController = MapController();

  LatLng _selectedLatLng = const LatLng(-6.2088, 106.8456); // default Jakarta
  double _radius = 50;
  bool _initializedFromData = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<OfficeProvider>().loadOffice();
      _applyLoadedData();
    });
  }

  void _applyLoadedData() {
    final office = context.read<OfficeProvider>().office;
    if (office != null && !_initializedFromData) {
      setState(() {
        _namaController.text = office.nama;
        _selectedLatLng = LatLng(office.latitude, office.longitude);
        _radius = office.radius;
        _initializedFromData = true;
      });
      _mapController.move(_selectedLatLng, 15);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama kantor tidak boleh kosong')),
      );
      return;
    }

    setState(() => _saving = true);

    final success = await context.read<OfficeProvider>().saveOffice(
          nama: _namaController.text.trim(),
          latitude: _selectedLatLng.latitude,
          longitude: _selectedLatLng.longitude,
          radius: _radius,
        );

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Pengaturan lokasi berhasil disimpan' : 'Gagal menyimpan pengaturan'),
      ),
    );
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text(
          'Pengaturan Lokasi Kantor',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined, color: AppColors.primary),
            onPressed: _saving ? null : _handleSave,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildMap(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Nama Kantor'),
                    const SizedBox(height: 8),
                    _buildNamaField(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Latitude'),
                              const SizedBox(height: 8),
                              _buildCoordField(_selectedLatLng.latitude.toStringAsFixed(4)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Longitude'),
                              const SizedBox(height: 8),
                              _buildCoordField(_selectedLatLng.longitude.toStringAsFixed(4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_searching_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            const Text(
                              'Radius Geofence',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_radius.toInt()} m',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.border,
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withOpacity(0.15),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _radius,
                        min: 10,
                        max: 500,
                        onChanged: (value) => setState(() => _radius = value),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('10m', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                        Text('500m', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildRadiusInfo(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _saving ? null : _handleSave,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.cloud_upload_outlined, size: 20),
                        label: Text(
                          _saving ? 'Menyimpan...' : 'Simpan Pengaturan',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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

  Widget _buildMap() {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLatLng,
              initialZoom: 15,
              onTap: (tapPosition, latLng) {
                setState(() => _selectedLatLng = latLng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tera.attendance', // ganti sesuai package name app kamu
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _selectedLatLng,
                    radius: _radius,
                    useRadiusInMeter: true,
                    color: AppColors.primary.withOpacity(0.12),
                    borderColor: AppColors.primary,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLatLng,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on_rounded, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.gps_fixed_rounded, size: 14, color: Colors.green),
                  SizedBox(width: 4),
                  Text('Akurasi: 5m', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app_outlined, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Ketuk peta untuk pilih lokasi', style: TextStyle(fontSize: 12, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }

  Widget _buildNamaField() {
    return TextField(
      controller: _namaController,
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.apartment_rounded, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildCoordField(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildRadiusInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Radius aktif: ${_radius.toInt()} meter',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.success),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Karyawan dapat absen di dalam area ini.',
                  style: TextStyle(fontSize: 12, color: AppColors.success),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
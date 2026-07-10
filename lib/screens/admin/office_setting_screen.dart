import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/office_provider.dart';

class _SearchResult {
  final String displayName;
  final LatLng latLng;

  _SearchResult({required this.displayName, required this.latLng});
}

class OfficeSettingScreen extends StatefulWidget {
  const OfficeSettingScreen({super.key});

  @override
  State<OfficeSettingScreen> createState() => _OfficeSettingScreenState();
}

class _OfficeSettingScreenState extends State<OfficeSettingScreen> {
  final _namaController = TextEditingController();
  final _searchController = TextEditingController();
  final MapController _mapController = MapController();

  LatLng _selectedLatLng = const LatLng(-6.2088, 106.8456); // default Jakarta
  double _radius = 50;
  bool _initializedFromData = false;
  bool _saving = false;

  List<_SearchResult> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

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
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      setState(() => _searchResults = []);
      return;
    }
    // Debounce 700ms supaya tidak spam request tiap ketikan (hormati rate limit Nominatim)
    _debounce = Timer(const Duration(milliseconds: 700), () => _searchPlace(query));
  }

  Future<void> _searchPlace(String query) async {
    setState(() => _isSearching = true);

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeQueryComponent(query)}'
        '&format=json&limit=5&addressdetails=0',
      );

      final response = await http.get(
        uri,
        headers: {
          // Wajib diisi sesuai kebijakan Nominatim, ganti sesuai identitas app kamu
          'User-Agent': 'TERA-Attendance-App/1.0 (contact: fauzimaulanaakbarr@gmail.com)',

        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _searchResults = data.map((item) {
            return _SearchResult(
              displayName: item['display_name'] ?? '-',
              latLng: LatLng(
                double.parse(item['lat']),
                double.parse(item['lon']),
              ),
            );
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('❌ Nominatim search error: $e');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSearchResult(_SearchResult result) {
    setState(() {
      _selectedLatLng = result.latLng;
      _searchResults = [];
      _searchController.clear();
    });
    _mapController.move(result.latLng, 16);
    FocusScope.of(context).unfocus();
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
            _buildMapWithSearch(),
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

  Widget _buildMapWithSearch() {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedLatLng,
                  initialZoom: 15,
                  onTap: (tapPosition, latLng) {
                    setState(() {
                      _selectedLatLng = latLng;
                      _searchResults = [];
                    });
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
            ),
          ),
          // Search bar
          Positioned(
            top: 0,
            left: 12,
            right: 12,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Cari nama gedung atau alamat...',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
                      prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.textHint),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : (_searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchResults = []);
                                  },
                                )
                              : null),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    constraints: const BoxConstraints(maxHeight: 180),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                          title: Text(
                            result.displayName,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _selectSearchResult(result),
                        );
                      },
                    ),
                  ),
              ],
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
                    Text('Cari atau ketuk peta untuk pilih lokasi', style: TextStyle(fontSize: 12, color: Colors.white)),
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
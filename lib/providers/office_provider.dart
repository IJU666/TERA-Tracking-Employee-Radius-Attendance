import 'package:flutter/material.dart';
// import '../models/office_model.dart';
// import '../repositories/office_repository.dart';

class OfficeProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // OfficeModel? _officeConfig;
  // OfficeModel? get officeConfig => _officeConfig;

  Future<void> fetchOfficeConfig() async {
    _isLoading = true;
    // Hindari notifyListeners berlebih jika dipanggil saat build
    
    try {
      // TODO: Get office data (lat, lng, radius) dari repository
      // _officeConfig = await _officeRepository.getOffice();
    } catch (e) {
      debugPrint("Error fetching office config: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
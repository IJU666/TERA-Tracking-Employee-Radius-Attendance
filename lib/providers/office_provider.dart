import 'package:flutter/material.dart';
import '../models/office_model.dart';
import '../repositories/office_repository.dart';

class OfficeProvider extends ChangeNotifier {
  final OfficeRepository _repository = OfficeRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  OfficeModel? _office;
  OfficeModel? get office => _office;

  Future<void> loadOffice() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _office = await _repository.getOffice();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Error load office: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveOffice({
    required String nama,
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = OfficeModel(
        id: _office?.id ?? 'office',
        nama: nama,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      // 1. Simpan data baru ke Firestore
      await _repository.updateOffice(updated);
      
      // 2. Ambil ulang data dari Firestore agar 'updatedAt' dari server tersinkron ke lokal
      _office = await _repository.getOffice();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ Error save office: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
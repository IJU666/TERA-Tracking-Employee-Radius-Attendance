import 'package:cloud_firestore/cloud_firestore.dart';

class OfficeModel {
  final String id;
  final String nama;
  final double latitude;
  final double longitude;
  final double radius; // dalam meter
  final DateTime? updatedAt; // Tambahan untuk tracking perubahan terakhir

  const OfficeModel({
    required this.id,
    required this.nama,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.updatedAt,
  });

  OfficeModel copyWith({
    String? id,
    String? nama,
    double? latitude,
    double? longitude,
    double? radius,
    DateTime? updatedAt,
  }) {
    return OfficeModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory OfficeModel.fromMap(Map<String, dynamic> map, String id) {
    return OfficeModel(
      id: id,
      nama: map['nama'] ?? '-',
      // Amankan casting menggunakan 'as num?' sebelum diubah ke double
      // Ini mencegah crash jika Firestore tidak sengaja menyimpannya sebagai int
      latitude: (map['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (map['longitude'] as num? ?? 0.0).toDouble(),
      radius: (map['radius'] as num? ?? 50.0).toDouble(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      // Otomatis mencatat waktu server Firebase saat data disimpan/diubah
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
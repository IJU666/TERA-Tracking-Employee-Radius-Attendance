import 'package:cloud_firestore/cloud_firestore.dart';

class OfficeModel {
  final String id;
  final String nama;
  final double latitude;
  final double longitude;
  final double radius; // dalam meter
  final String? jamMasuk; // 🟢 Field Baru: Menyimpan format "HH:mm"
  final int? toleransi;   // 🟢 Field Baru: Menyimpan angka menit toleransi
  final DateTime? updatedAt; 

  const OfficeModel({
    required this.id,
    required this.nama,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.jamMasuk, // 🟢 Masuk ke constructor
    this.toleransi, // 🟢 Masuk ke constructor
    this.updatedAt,
  });

  OfficeModel copyWith({
    String? id,
    String? nama,
    double? latitude,
    double? longitude,
    double? radius,
    String? jamMasuk, // 🟢 Ditambahkan ke copyWith
    int? toleransi,   // 🟢 Ditambahkan ke copyWith
    DateTime? updatedAt,
  }) {
    return OfficeModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      jamMasuk: jamMasuk ?? this.jamMasuk, // 🟢 Ditambahkan ke copyWith
      toleransi: toleransi ?? this.toleransi, // 🟢 Ditambahkan ke copyWith
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory OfficeModel.fromMap(Map<String, dynamic> map, String id) {
    return OfficeModel(
      id: id,
      nama: map['nama'] ?? '-',
      latitude: (map['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (map['longitude'] as num? ?? 0.0).toDouble(),
      radius: (map['radius'] as num? ?? 50.0).toDouble(),
      jamMasuk: map['jam_masuk'] as String?, // 🟢 Mapping data dari Firestore
      toleransi: map['toleransi_menit'] as int?, // 🟢 Mapping data dari Firestore
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
      'jam_masuk': jamMasuk, // 🟢 Disimpan ke Firestore
      'toleransi_menit': toleransi, // 🟢 Disimpan ke Firestore
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
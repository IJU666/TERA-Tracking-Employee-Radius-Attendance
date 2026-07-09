class OfficeModel {
  final String id;
  final String nama;
  final double latitude;
  final double longitude;
  final double radius; // dalam meter

  const OfficeModel({
    required this.id,
    required this.nama,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  OfficeModel copyWith({
    String? id,
    String? nama,
    double? latitude,
    double? longitude,
    double? radius,
  }) {
    return OfficeModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
    );
  }

  factory OfficeModel.fromMap(Map<String, dynamic> map, String id) {
    return OfficeModel(
      id: id,
      nama: map['nama'] ?? '-',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      radius: (map['radius'] ?? 50).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }
} 
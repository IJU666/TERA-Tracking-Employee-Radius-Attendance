/// Data titik lokasi saat check-in/check-out (nested di dalam AttendanceModel).
class CheckPointModel {
  final DateTime timestamp;
  final double lat;
  final double lng;
  final double distance; // jarak ke titik kantor, dalam meter

  const CheckPointModel({
    required this.timestamp,
    required this.lat,
    required this.lng,
    required this.distance,
  });

  factory CheckPointModel.fromMap(Map<String, dynamic> map) {
    return CheckPointModel(
      timestamp: DateTime.parse(map['timestamp']),
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      distance: (map['distance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'lat': lat,
      'lng': lng,
      'distance': distance,
    };
  }
}

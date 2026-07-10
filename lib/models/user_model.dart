/// Model data karyawan / pengguna aplikasi.
class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String nik;
  final String divisi;
  final String jabatan;
  final String role; // 'karyawan' atau 'admin'
  final String? avatarUrl;
  final int sisaCuti;
  final int totalCuti;

  const UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.nik,
    required this.divisi,
    required this.jabatan,
    required this.role,
    required this.sisaCuti,
    required this.totalCuti,
    this.avatarUrl,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      nik: map['nik'] ?? '',
      divisi: map['divisi'] ?? '',
      jabatan: map['jabatan'] ?? '',
      role: map['role'] ?? 'karyawan',
      avatarUrl: map['avatarUrl'] ?? '',
      sisaCuti: map['sisa_cuti'] ?? 14,   
      totalCuti: map['total_cuti'] ?? 14,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'email': email,
      'nik': nik,
      'divisi': divisi,
      'jabatan': jabatan,
      'role': role,
      'avatarUrl': avatarUrl,
      'sisa_cuti': sisaCuti,
      'total_cuti': totalCuti,
      
    };
  }

  UserModel copyWith({
    String? nama,
    String? email,
    String? nik,
    String? divisi,
    String? jabatan,
    String? role,
    String? avatarUrl,
    int? sisaCuti,
    int? totalCuti,
  }) {
    return UserModel(
      uid: uid,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      nik: nik ?? this.nik,
      divisi: divisi ?? this.divisi,
      jabatan: jabatan ?? this.jabatan,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      sisaCuti: sisaCuti ?? this.sisaCuti,
      totalCuti: totalCuti ?? this.totalCuti,
    );
  }
}

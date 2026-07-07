/// Model data karyawan / pengguna aplikasi.
class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String nik;
  final String divisi;
  final String jabatan;
  final String role; // 'karyawan' atau 'admin'
  final String? fotoUrl;

  const UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.nik,
    required this.divisi,
    required this.jabatan,
    required this.role,
    this.fotoUrl,
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
      fotoUrl: map['fotoUrl'],
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
      'fotoUrl': fotoUrl,
    };
  }

  UserModel copyWith({
    String? nama,
    String? email,
    String? nik,
    String? divisi,
    String? jabatan,
    String? role,
    String? fotoUrl,
  }) {
    return UserModel(
      uid: uid,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      nik: nik ?? this.nik,
      divisi: divisi ?? this.divisi,
      jabatan: jabatan ?? this.jabatan,
      role: role ?? this.role,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }
}

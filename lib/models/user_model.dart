/// Model data karyawan / pengguna aplikasi.
class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String nik;
  final String divisi;
  final String jabatan;
  final String role; // 'karyawan', 'admin', atau 'manager'
  final String? avatarUrl;
  final int sisaCuti;
  final int totalCuti;
  final RingkasanBulanan ringkasanBulanan;

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
    required this.ringkasanBulanan,
    this.avatarUrl,
  });

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';

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
      ringkasanBulanan: RingkasanBulanan.fromMap(map['ringkasanBulanan'] ?? {}),
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
      'ringkasanBulanan': ringkasanBulanan.toMap(),
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
    RingkasanBulanan? ringkasanBulanan,
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
      ringkasanBulanan: ringkasanBulanan ?? this.ringkasanBulanan,
    );
  }
}

class RingkasanBulanan {
  final int hadir;
  final int izin;
  final int cuti;
  final int telat;

  const RingkasanBulanan({
    this.hadir = 0,
    this.izin = 0,
    this.cuti = 0,
    this.telat = 0,
  });

  factory RingkasanBulanan.fromMap(Map<dynamic, dynamic> map) {
    return RingkasanBulanan(
      hadir: map['hadir'] ?? 0,
      izin: map['izin'] ?? 0,
      cuti: map['cuti'] ?? 0,
      telat: map['telat'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hadir': hadir,
      'izin': izin,
      'cuti': cuti,
      'telat': telat,
    };
  }
}
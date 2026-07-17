/// Model data karyawan / pengguna aplikasi.
class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String nik;
  final String divisi;
  final String jabatan;
  final String role; // 'karyawan', 'admin', atau 'manager'
  final String? fotoUrl;
  final RingkasanBulanan ringkasanBulanan;

  const UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.nik,
    required this.divisi,
    required this.jabatan,
    required this.role,
    this.fotoUrl,
    required this.ringkasanBulanan,
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
      fotoUrl: map['avatarUrl'] ?? '', // Mapping database
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
      'avatarUrl': fotoUrl, // Menggunakan penulisan seragam di Firestore
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
    String? fotoUrl,
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
      fotoUrl: fotoUrl ?? this.fotoUrl,
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
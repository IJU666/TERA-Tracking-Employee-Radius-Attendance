class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String nik;
  final String divisi;
  final String jabatan;
  final String role; // 'karyawan' atau 'admin'
  final String fotoUrl;

  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.nik,
    required this.divisi,
    required this.jabatan,
    required this.role,
    required this.fotoUrl,
  });

  // --- BAGIAN INI UNTUK MENYELESAIKAN ERROR FROMJSON ---
  // Mengonversi data Map/JSON dari Firebase menjadi Objek UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      nik: json['nik'] ?? '',
      divisi: json['divisi'] ?? '',
      jabatan: json['jabatan'] ?? '',
      role: json['role'] ?? 'karyawan', // default sebagai karyawan jika kosong
      fotoUrl: json['fotoUrl'] ?? '',
    );
  }

  // Mengonversi Objek UserModel kembali ke Map/JSON (berguna saat tambah/edit karyawan nanti)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nama': nama,
      'email': email,
      'nik': nik,
      'divisi': divisi,
      'jabatan': jabatan,
      'role': role,
      'fotoUrl': fotoUrl,
    };
  }
}
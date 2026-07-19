import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Service untuk upload file ke Firebase Storage.
/// Dipakai untuk foto profil (edit_profile_screen) dan nanti foto
/// presensi (absen_screen).
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload foto profil, path: profile_photos/{uid}.jpg
  /// Return download URL yang siap disimpan ke field `avatarUrl` di
  /// Firestore.
  Future<String> uploadProfilePhoto(String uid, File file) async {
    final ref = _storage.ref().child('profile_photos').child('$uid.jpg');
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  /// Upload foto presensi (selfie check-in/check-out).
  /// path: attendance_photos/{uid}/{timestampMs}.jpg
  Future<String> uploadAttendancePhoto(String uid, File file) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage
        .ref()
        .child('attendance_photos')
        .child(uid)
        .child(fileName);
    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }
}
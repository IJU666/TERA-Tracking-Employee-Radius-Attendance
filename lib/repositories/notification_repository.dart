import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

/// Repository untuk data notifikasi di sub-koleksi milik user
/// Jalur Firestore: users/{uid}/notifications/{id}
class NotificationRepository {
  
  // 🎯 PERUBAHAN DI SINI: Jalur dipindahkan ke dalam subkoleksi dokumen user
  CollectionReference _itemsRef(String uid) => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('notifications');

  Stream<List<NotificationModel>> getByUid(String uid) {
    return _itemsRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> markAsRead(String uid, String id) async {
    await _itemsRef(uid).doc(id).update({'isRead': true});
  }

  Future<void> markAllRead(String uid) async {
    final snapshot =
        await _itemsRef(uid).where('isRead', isEqualTo: false).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> create(String uid, NotificationModel notification) async {
    await _itemsRef(uid).add(notification.toMap());
  }
}
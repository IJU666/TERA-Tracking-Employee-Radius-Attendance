import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

/// Provider untuk list notifikasi & unread count (badge lonceng di home_screen).
class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  List<NotificationModel> _notifications = [];
  StreamSubscription<List<NotificationModel>>? _subscription;

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Mulai dengarkan notifikasi realtime. Panggil sekali saat home_screen
  /// pertama kali dibuka (misalnya lewat splash_screen atau initState).
  void listen() {
    final uid = _uid;
    if (uid == null) return;

    _subscription?.cancel();
    _subscription = _repository.getByUid(uid).listen((data) {
      _notifications = data;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _repository.markAsRead(uid, id);
  }

  Future<void> markAllRead() async {
    final uid = _uid;
    if (uid == null) return;
    await _repository.markAllRead(uid);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

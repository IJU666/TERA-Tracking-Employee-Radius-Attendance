import 'package:flutter/material.dart';
// import '../models/notification_model.dart';
// import '../repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // List<NotificationModel> _notifications = [];
  // List<NotificationModel> get notifications => _notifications;

  int get unreadCount {
    // return _notifications.where((n) => !n.isRead).length;
    return 0; // Placeholder
  }

  Future<void> fetchNotifications(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Stream atau Get notifikasi dari Firestore
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    // TODO: Update status isRead menjadi true di database
    notifyListeners();
  }
}
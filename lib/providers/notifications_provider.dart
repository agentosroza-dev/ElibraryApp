import 'dart:async';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/notifications_model.dart';
import '../services/api_client.dart';
import '../services/local_notification_service.dart';

class NotificationsProvider extends ChangeNotifier {
  final ApiClient _client = ApiClient();

  List<NotificationItem> _notificationList = [];
  List<NotificationItem> get notificationList => _notificationList;

  final Set<String> _knownIds = {};
  bool _firstCheckDone = false;
  int _notifCounter = 0;
  String _unreadCount = '0';
  String get unreadCount => _unreadCount;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Timer? _pollTimer;

  void startPolling() {
    _pollTimer?.cancel();
    _checkForNewNotifications();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkForNewNotifications();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _checkForNewNotifications() async {
    try {
      final response = await _client.get(
        ApiConfig.notifications,
        authenticate: true,
      );
      final list = response['notifications'] as List;
      final items = list
          .map((x) => NotificationItem.fromJson(x as Map<String, dynamic>))
          .toList();

      for (final item in items) {
        if (!_knownIds.contains(item.id)) {
          if (_firstCheckDone || item.readAt == 'null' || item.readAt.isEmpty) {
            _notifCounter++;
            await LocalNotificationService.instance.showNotification(
              id: _notifCounter,
              title: item.title,
              body: item.message,
              payload: item.itemId,
            );
          }
        }
      }
      _knownIds.addAll(items.map((e) => e.id));
      _firstCheckDone = true;
    } catch (e) {
      debugPrint('Notification check error: $e');
    }
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (!refresh && _notificationList.isNotEmpty) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client.get(
        ApiConfig.notifications,
        authenticate: true,
      );
      final list = response['notifications'] as List;
      final items = list
          .map((x) => NotificationItem.fromJson(x as Map<String, dynamic>))
          .toList();
      _knownIds.addAll(items.map((e) => e.id));
      _firstCheckDone = true;
      _notificationList = items;
      _unreadCount = '${response["unread_count"]}';
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _client.patch(
        ApiConfig.notificationRead(int.parse(id)),
        authenticate: true,
      );
      await fetchNotifications(refresh: true);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _client.patch(
        ApiConfig.notificationReadAll,
        authenticate: true,
      );
      await fetchNotifications(refresh: true);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    try {
      await _client.delete(
        ApiConfig.notificationClearAll,
        authenticate: true,
      );
      _notificationList.clear();
      _unreadCount = '0';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

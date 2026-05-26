import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import 'notifications_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final _client = ApiClient.instance;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _client.get(ApiConstants.notifications);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data is List ? data : (data['results'] ?? []);
      return (list as List)
          .map((j) => NotificationModel.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load notifications (${response.statusCode})');
  }

  @override
  Future<void> markAsRead(int id) async {
    final response = await _client.post('${ApiConstants.notifications}$id/read/');
    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final response = await _client.post(ApiConstants.readAllNotifs);
    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read');
    }
  }
}

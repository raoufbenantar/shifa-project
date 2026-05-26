import 'notifications_entity.dart';

abstract class NotificationsRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
}

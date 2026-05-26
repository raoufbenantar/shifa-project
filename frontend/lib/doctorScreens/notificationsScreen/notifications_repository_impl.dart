import 'notifications_entity.dart';
import 'notifications_remote_datasource.dart';
import 'notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _ds;
  NotificationsRepositoryImpl(this._ds);

  @override
  Future<List<NotificationEntity>> getNotifications() => _ds.getNotifications();

  @override
  Future<void> markAsRead(int id) => _ds.markAsRead(id);

  @override
  Future<void> markAllAsRead() => _ds.markAllAsRead();
}

import 'notifications_entity.dart';
import 'notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository _repo;
  GetNotificationsUseCase(this._repo);
  Future<List<NotificationEntity>> call() => _repo.getNotifications();
}

class MarkNotificationAsReadUseCase {
  final NotificationsRepository _repo;
  MarkNotificationAsReadUseCase(this._repo);
  Future<void> call(int id) => _repo.markAsRead(id);
}

class MarkAllNotificationsAsReadUseCase {
  final NotificationsRepository _repo;
  MarkAllNotificationsAsReadUseCase(this._repo);
  Future<void> call() => _repo.markAllAsRead();
}

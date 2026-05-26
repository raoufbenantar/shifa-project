import 'package:flutter_bloc/flutter_bloc.dart';
import 'notifications_entity.dart';
import 'notifications_usecase.dart';

abstract class NotificationsState {}
class NotificationsInitial extends NotificationsState {}
class NotificationsLoading extends NotificationsState {}
class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> list;
  NotificationsLoaded(this.list);
}
class NotificationsError extends NotificationsState {
  final String message;
  NotificationsError(this.message);
}

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationAsReadUseCase _markRead;
  final MarkAllNotificationsAsReadUseCase _markAllRead;

  NotificationsCubit(this._getNotifications, this._markRead, this._markAllRead)
      : super(NotificationsInitial());

  Future<void> load() async {
    emit(NotificationsLoading());
    try {
      final list = await _getNotifications();
      emit(NotificationsLoaded(list));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _markRead(id);
      await load();
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _markAllRead();
      await load();
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }
}

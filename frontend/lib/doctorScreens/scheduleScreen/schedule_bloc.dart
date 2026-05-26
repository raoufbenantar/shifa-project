import 'schedule_entity.dart';

abstract class ScheduleEvent {}
class LoadSchedule extends ScheduleEvent {}
class RefreshSchedule extends ScheduleEvent {}
class SelectScheduleDate extends ScheduleEvent {
  final DateTime date;
  SelectScheduleDate(this.date);
}
class ConfirmScheduleAppointment extends ScheduleEvent {
  final int id;
  ConfirmScheduleAppointment(this.id);
}
class RejectScheduleAppointment extends ScheduleEvent {
  final int id;
  RejectScheduleAppointment(this.id);
}

abstract class ScheduleState {}
class ScheduleInitial extends ScheduleState {}
class ScheduleLoading extends ScheduleState {}
class ScheduleLoaded extends ScheduleState {
  final List<ScheduleAppointment> all;
  final DateTime selectedDate;
  List<ScheduleAppointment> get forSelectedDate => all
      .where((a) {
        final dt = DateTime.tryParse(a.scheduledDatetime)?.toLocal();
        if (dt == null) return false;
        return dt.year == selectedDate.year &&
            dt.month == selectedDate.month &&
            dt.day == selectedDate.day;
      })
      .toList()
    ..sort((a, b) =>
        DateTime.parse(a.scheduledDatetime)
            .compareTo(DateTime.parse(b.scheduledDatetime)));
  ScheduleLoaded(this.all, this.selectedDate);
}
class ScheduleError extends ScheduleState {
  final String message;
  ScheduleError(this.message);
}
class ScheduleActionInProgress extends ScheduleState {
  final int appointmentId;
  ScheduleActionInProgress(this.appointmentId);
}

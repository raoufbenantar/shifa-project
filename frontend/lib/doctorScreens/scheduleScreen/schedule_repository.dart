import 'schedule_entity.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleAppointment>> getAppointments();
  Future<void> confirmAppointment(int id);
  Future<void> rejectAppointment(int id);
}

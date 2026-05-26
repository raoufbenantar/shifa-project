import 'schedule_entity.dart';
import 'schedule_remote_datasource.dart';
import 'schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource _ds;
  ScheduleRepositoryImpl(this._ds);

  @override
  Future<List<ScheduleAppointment>> getAppointments() => _ds.getAppointments();

  @override
  Future<void> confirmAppointment(int id) => _ds.confirmAppointment(id);

  @override
  Future<void> rejectAppointment(int id) => _ds.rejectAppointment(id);
}

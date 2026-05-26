import 'schedule_entity.dart';
import 'schedule_repository.dart';

class GetScheduleUseCase {
  final ScheduleRepository _repo;
  GetScheduleUseCase(this._repo);
  Future<List<ScheduleAppointment>> call() => _repo.getAppointments();
}

class ConfirmAppointmentUseCase {
  final ScheduleRepository _repo;
  ConfirmAppointmentUseCase(this._repo);
  Future<void> call(int id) => _repo.confirmAppointment(id);
}

class RejectAppointmentUseCase {
  final ScheduleRepository _repo;
  RejectAppointmentUseCase(this._repo);
  Future<void> call(int id) => _repo.rejectAppointment(id);
}

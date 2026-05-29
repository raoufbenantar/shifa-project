import 'booking_entity.dart';
import 'booking_repository.dart';

class GetDoctorsUseCase {
  final BookingRepository _repo;
  GetDoctorsUseCase(this._repo);
  Future<List<DoctorEntity>> call({String? search, String? specialization}) =>
      _repo.getDoctors(search: search, specialization: specialization);
}

class GetDoctorClinicsUseCase {
  final BookingRepository _repo;
  GetDoctorClinicsUseCase(this._repo);
  Future<List<DoctorClinicEntity>> call(int doctorId) =>
      _repo.getDoctorClinics(doctorId);
}

class GetAvailableSlotsUseCase {
  final BookingRepository _repo;
  GetAvailableSlotsUseCase(this._repo);
  Future<List<AvailableSlotEntity>> call({
    required int doctorId,
    required int clinicId,
    required String date,
  }) =>
      _repo.getAvailableSlots(
          doctorId: doctorId, clinicId: clinicId, date: date);
}

class BookAppointmentUseCase {
  final BookingRepository _repo;
  BookAppointmentUseCase(this._repo);
  Future<PatientAppointmentEntity> call({
    required int doctorId,
    required int clinicId,
    required String scheduledDatetime,
    required String consultationType,
    String? notes,
  }) =>
      _repo.bookAppointment(
        doctorId: doctorId,
        clinicId: clinicId,
        scheduledDatetime: scheduledDatetime,
        consultationType: consultationType,
        notes: notes,
      );
}

class GetMyAppointmentsUseCase {
  final BookingRepository _repo;
  GetMyAppointmentsUseCase(this._repo);
  Future<List<PatientAppointmentEntity>> call() => _repo.getMyAppointments();
}

class CancelAppointmentUseCase {
  final BookingRepository _repo;
  CancelAppointmentUseCase(this._repo);
  Future<void> call(int id) => _repo.cancelAppointment(id);
}

class RescheduleAppointmentUseCase {
  final BookingRepository _repo;
  RescheduleAppointmentUseCase(this._repo);
  Future<PatientAppointmentEntity> call(int id, String newDatetime) =>
      _repo.rescheduleAppointment(id, newDatetime);
}

class GetClinicsUseCase {
  final BookingRepository _repo;
  GetClinicsUseCase(this._repo);
  Future<List<ClinicEntity>> call() => _repo.getClinics();
}

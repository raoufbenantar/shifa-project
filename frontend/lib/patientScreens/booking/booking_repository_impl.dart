import 'booking_entity.dart';
import 'booking_remote_datasource.dart';
import 'booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _ds;

  BookingRepositoryImpl(this._ds);

  @override
  Future<List<DoctorEntity>> getDoctors({
    String? search,
    String? specialization,
  }) =>
      _ds.getDoctors(search: search, specialization: specialization);

  @override
  Future<List<ClinicEntity>> getClinics() => _ds.getClinics();

  @override
  Future<List<DoctorClinicEntity>> getDoctorClinics(int doctorId) =>
      _ds.getDoctorClinics(doctorId);

  @override
  Future<List<AvailableSlotEntity>> getAvailableSlots({
    required int doctorId,
    required int clinicId,
    required String date,
  }) =>
      _ds.getAvailableSlots(
          doctorId: doctorId, clinicId: clinicId, date: date);

  @override
  Future<PatientAppointmentEntity> bookAppointment({
    required int doctorId,
    required int clinicId,
    required String scheduledDatetime,
    required String consultationType,
    String? notes,
  }) =>
      _ds.bookAppointment(
        doctorId: doctorId,
        clinicId: clinicId,
        scheduledDatetime: scheduledDatetime,
        consultationType: consultationType,
        notes: notes,
      );

  @override
  Future<List<PatientAppointmentEntity>> getMyAppointments() =>
      _ds.getMyAppointments();

  @override
  Future<void> cancelAppointment(int id) => _ds.cancelAppointment(id);

  @override
  Future<PatientAppointmentEntity> rescheduleAppointment(
          int id, String newDatetime) =>
      _ds.rescheduleAppointment(id, newDatetime);
}

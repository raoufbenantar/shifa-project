import 'booking_entity.dart';

/// Abstract repository for the booking domain.
abstract class BookingRepository {
  Future<List<DoctorEntity>> getDoctors({String? search, String? specialization});
  Future<List<ClinicEntity>> getClinics();
  Future<List<DoctorClinicEntity>> getDoctorClinics(int doctorId);
  Future<List<AvailableSlotEntity>> getAvailableSlots({
    required int doctorId,
    required int clinicId,
    required String date,
  });
  Future<PatientAppointmentEntity> bookAppointment({
    required int doctorId,
    required int clinicId,
    required String scheduledDatetime,
    required String consultationType,
    String? notes,
  });
  Future<List<PatientAppointmentEntity>> getMyAppointments();
  Future<void> cancelAppointment(int id);
  Future<PatientAppointmentEntity> rescheduleAppointment(
      int id, String newDatetime);
}

import 'schedule_entity.dart';

class ScheduleAppointmentModel extends ScheduleAppointment {
  const ScheduleAppointmentModel({
    required super.id,
    required super.patientName,
    required super.scheduledDatetime,
    required super.status,
    required super.consultationType,
    super.clinicName,
    required super.clinicId,
    required super.doctorId,
  });

  factory ScheduleAppointmentModel.fromJson(Map<String, dynamic> json) {
    final patient = json['patient_details'] as Map<String, dynamic>?;
    final clinic  = json['clinic_details']  as Map<String, dynamic>?;
    return ScheduleAppointmentModel(
      id:                json['id'],
      patientName:       patient?['full_name'] ?? 'Unknown',
      scheduledDatetime: json['scheduled_datetime'],
      status:            json['status'],
      consultationType:  json['consultation_type'],
      clinicName:        clinic?['name'],
      clinicId:          json['clinic'],
      doctorId:          json['doctor'],
    );
  }
}

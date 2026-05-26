class ScheduleAppointment {
  final int id;
  final String patientName;
  final String scheduledDatetime;
  final String status;
  final String consultationType;
  final String? clinicName;
  final int clinicId;
  final int doctorId;

  const ScheduleAppointment({
    required this.id,
    required this.patientName,
    required this.scheduledDatetime,
    required this.status,
    required this.consultationType,
    this.clinicName,
    required this.clinicId,
    required this.doctorId,
  });
}

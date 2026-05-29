import 'patient_dashboard_entity.dart';

class PatientDashboardModel extends PatientDashboardEntity {
  const PatientDashboardModel({
    required super.patient,
    required super.stats,
    super.upcomingAppointment,
    required super.recentPrescriptions,
    required super.unreadNotificationsCount,
    required super.unreadMessagesCount,
  });

  factory PatientDashboardModel.fromJson(Map<String, dynamic> json) {
    final patientJson = json['patient'] as Map<String, dynamic>;
    final statsJson = json['stats'] as Map<String, dynamic>;

    UpcomingAppointmentEntity? upcoming;
    if (json['upcoming_appointment'] != null) {
      final u = json['upcoming_appointment'] as Map<String, dynamic>;
      final doctorDetails = u['doctor_details'] as Map<String, dynamic>?;
      final clinicDetails = u['clinic_details'] as Map<String, dynamic>?;
      upcoming = UpcomingAppointmentEntity(
        id: u['id'],
        doctorName: doctorDetails?['full_name'] ?? 'Unknown',
        doctorSpecialization: doctorDetails?['specialization'] ?? '',
        clinicName: clinicDetails?['name'] ?? '',
        scheduledDatetime: u['scheduled_datetime'],
        status: u['status'],
        consultationType: u['consultation_type'],
      );
    }

    return PatientDashboardModel(
      patient: PatientInfo(
        id: patientJson['id'],
        fullName: patientJson['full_name'],
        phoneNumber: patientJson['phone_number'] ?? '',
        email: patientJson['email'],
      ),
      stats: PatientStats(
        totalAppointments: statsJson['total_appointments'],
        completed: statsJson['completed'],
        canceled: statsJson['canceled'],
        pending: statsJson['pending'],
        confirmed: statsJson['confirmed'],
      ),
      upcomingAppointment: upcoming,
      recentPrescriptions: _parsePrescriptions(json['recent_prescriptions']),
      unreadNotificationsCount: json['unread_notifications_count'] ?? 0,
      unreadMessagesCount: json['unread_messages_count'] ?? 0,
    );
  }

  static List<PrescriptionSummaryEntity> _parsePrescriptions(dynamic list) {
    if (list == null) return [];
    return (list as List).map((item) {
      final p = item as Map<String, dynamic>;
      return PrescriptionSummaryEntity(
        id: p['id'],
        medicationName: p['medication_name'] ?? 'Unknown',
        dosage: p['dosage'] ?? '',
        durationDays: p['duration_days'] ?? 0,
        doctorName: p['doctor_name'] ?? '',
        date: p['date'] ?? '',
      );
    }).toList();
  }
}

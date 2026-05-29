class PatientDashboardEntity {
  final PatientInfo patient;
  final PatientStats stats;
  final UpcomingAppointmentEntity? upcomingAppointment;
  final List<PrescriptionSummaryEntity> recentPrescriptions;
  final int unreadNotificationsCount;
  final int unreadMessagesCount;

  const PatientDashboardEntity({
    required this.patient,
    required this.stats,
    this.upcomingAppointment,
    required this.recentPrescriptions,
    required this.unreadNotificationsCount,
    required this.unreadMessagesCount,
  });
}

class PatientInfo {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String email;

  const PatientInfo({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
  });
}

class PatientStats {
  final int totalAppointments;
  final int completed;
  final int canceled;
  final int pending;
  final int confirmed;

  const PatientStats({
    required this.totalAppointments,
    required this.completed,
    required this.canceled,
    required this.pending,
    required this.confirmed,
  });
}

class UpcomingAppointmentEntity {
  final int id;
  final String doctorName;
  final String doctorSpecialization;
  final String clinicName;
  final String scheduledDatetime;
  final String status;
  final String consultationType;

  const UpcomingAppointmentEntity({
    required this.id,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.clinicName,
    required this.scheduledDatetime,
    required this.status,
    required this.consultationType,
  });
}

class PrescriptionSummaryEntity {
  final int id;
  final String medicationName;
  final String dosage;
  final int durationDays;
  final String doctorName;
  final String date;

  const PrescriptionSummaryEntity({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.durationDays,
    required this.doctorName,
    required this.date,
  });
}

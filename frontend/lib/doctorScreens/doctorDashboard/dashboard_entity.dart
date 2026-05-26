class DashboardEntity {
  final DoctorInfo doctor;
  final DashboardStats stats;
  final List<AppointmentEntity> todayAppointments;
  final List<AppointmentEntity> pendingAppointments;
  final List<AppointmentEntity> upcomingAppointments;
  final int unreadMessages;
  final int unreadNotifications;

  const DashboardEntity({
    required this.doctor,
    required this.stats,
    required this.todayAppointments,
    required this.pendingAppointments,
    required this.upcomingAppointments,
    required this.unreadMessages,
    required this.unreadNotifications,
  });
}

class DoctorInfo {
  final int id;
  final String fullName;
  final String specialization;
  final bool isVerified;
  final String verificationStatus;
  final double consultationFee;
  final String? image;

  const DoctorInfo({
    required this.id,
    required this.fullName,
    required this.specialization,
    required this.isVerified,
    required this.verificationStatus,
    required this.consultationFee,
    this.image,
  });
}

class DashboardStats {
  final int totalAppointments;
  final int completed;
  final int canceled;
  final int pending;
  final int confirmed;
  final double completionRate;
  final double? avgRating;
  final int totalReviews;
  final int totalClinics;

  const DashboardStats({
    required this.totalAppointments,
    required this.completed,
    required this.canceled,
    required this.pending,
    required this.confirmed,
    required this.completionRate,
    this.avgRating,
    required this.totalReviews,
    required this.totalClinics,
  });
}

class AppointmentEntity {
  final int id;
  final String patientName;
  final String scheduledDatetime;
  final String status;
  final String consultationType;

  const AppointmentEntity({
    required this.id,
    required this.patientName,
    required this.scheduledDatetime,
    required this.status,
    required this.consultationType,
  });
}

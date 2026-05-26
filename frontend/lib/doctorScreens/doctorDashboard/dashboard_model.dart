import 'dashboard_entity.dart';

class DashboardModel extends DashboardEntity {
  const DashboardModel({
    required super.doctor,
    required super.stats,
    required super.todayAppointments,
    required super.pendingAppointments,
    required super.upcomingAppointments,
    required super.unreadMessages,
    required super.unreadNotifications,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final doctorJson = json['doctor'] as Map<String, dynamic>;
    final statsJson = json['stats'] as Map<String, dynamic>;

    return DashboardModel(
      doctor: DoctorInfo(
        id: doctorJson['id'],
        fullName: doctorJson['full_name'],
        specialization: doctorJson['specialization'],
        isVerified: doctorJson['is_verified'],
        verificationStatus: doctorJson['verification_status'],
        consultationFee: (doctorJson['consultation_fee'] as num).toDouble(),
        image: doctorJson['image'],
      ),
      stats: DashboardStats(
        totalAppointments: statsJson['total_appointments'],
        completed: statsJson['completed'],
        canceled: statsJson['canceled'],
        pending: statsJson['pending'],
        confirmed: statsJson['confirmed'],
        completionRate: (statsJson['completion_rate'] as num).toDouble(),
        avgRating: statsJson['avg_rating'] != null
            ? (statsJson['avg_rating'] as num).toDouble()
            : null,
        totalReviews: statsJson['total_reviews'],
        totalClinics: statsJson['total_clinics'],
      ),
      todayAppointments: _parseAppointments(json['today_appointments']),
      pendingAppointments: _parseAppointments(json['pending_appointments']),
      upcomingAppointments: _parseAppointments(json['upcoming_appointments']),
      unreadMessages: json['unread_messages'],
      unreadNotifications: json['unread_notifications'],
    );
  }

  static List<AppointmentEntity> _parseAppointments(dynamic list) {
    if (list == null) return [];
    return (list as List).map((item) {
      final a = item as Map<String, dynamic>;
      final patientDetails = a['patient_details'] as Map<String, dynamic>?;
      return AppointmentEntity(
        id: a['id'],
        patientName: patientDetails?['full_name'] ?? 'Unknown',
        scheduledDatetime: a['scheduled_datetime'],
        status: a['status'],
        consultationType: a['consultation_type'],
      );
    }).toList();
  }
}

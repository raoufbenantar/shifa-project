class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'SHIFA_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  // Auth
  static const String login        = '$baseUrl/api/auth/login/';
  static const String register     = '$baseUrl/api/auth/register/';
  static const String me           = '$baseUrl/api/auth/me/';
  static const String logout       = '$baseUrl/api/auth/logout/';

  // Dashboard
  static const String doctorDashboard = '$baseUrl/api/dashboard/doctor/';

  // Appointments
  static const String appointments    = '$baseUrl/api/appointments/';
  static const String availableSlots  = '$baseUrl/api/appointments/available-slots/';

  // Appointment messages (chat per appointment)
  static const String appointmentMessages = '$baseUrl/api/appointment-messages/';

  // Notifications
  static const String notifications  = '$baseUrl/api/notifications/';
  static const String unreadCount    = '$baseUrl/api/notifications/unread_count/';
  static const String readAllNotifs  = '$baseUrl/api/notifications/read_all/';

  // Reviews
  static const String reviews = '$baseUrl/api/reviews/';

  // Chat rooms
  static const String chatRooms = '$baseUrl/api/chat/';

  // Doctors / Patients
  static const String doctors  = '$baseUrl/api/doctors/';
  static const String patients = '$baseUrl/api/patients/';
}

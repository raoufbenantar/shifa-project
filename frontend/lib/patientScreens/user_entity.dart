// ─────────────────────────────────────────────────────────────
// DOMAIN LAYER → User Entity
//
// WHY a separate UserEntity for login?
// The login response from the backend returns data from
// TWO tables:
//   users            → id, email, role_id, is_active
//   patient_profiles → full_name, phone_number
//
// We model what the app actually USES after a successful
// login.  Nothing here knows about HTTP, JSON, or Flutter.
// This is a plain Dart class — the core of Clean Architecture.
//
// Database alignment (FINAL_DIAGRAM):
//   users.id        → kept in local storage for future API calls
//   users.email     → shown in profile
//   users.role_id   → validated to be 'patient' role
//   users.is_active → if false, login is blocked
//   patient_profiles.full_name → shown in home screen greeting
// ─────────────────────────────────────────────────────────────

class UserEntity {
  final int id;              // users.id
  final String email;        // users.email
  final String fullName;     // patient_profiles.full_name
  final String phoneNumber;  // patient_profiles.phone_number
  final int roleId;          // users.role_id  (1=patient, 2=doctor)
  final bool isActive;       // users.is_active
  final String token;        // JWT returned by the backend

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.roleId,
    required this.isActive,
    required this.token,
  });
}

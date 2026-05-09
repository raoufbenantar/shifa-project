// ─────────────────────────────────────────────────────────────
// DOMAIN LAYER → Entity
//
// WHY an Entity in Clean Architecture?
// The Domain layer must be completely independent of Flutter,
// HTTP, or any framework.  An Entity is a plain Dart class that
// represents the core business object.
//
// Database alignment (FINAL_DIAGRAM):
//   users          → email, password_hash, role_id, is_active
//   patient_profiles → full_name, phone_number, date_of_birth,
//                      gender (we capture gender via National ID
//                      presence; backend derives it)
//
// The backend performs a DUAL INSERT:
//   1. INSERT INTO users (email, password_hash, role_id) → get user_id
//   2. INSERT INTO patient_profiles (user_id, full_name,
//      phone_number, date_of_birth) using returned user_id
// ─────────────────────────────────────────────────────────────

class SignupEntity {
  final String fullName;       // → patient_profiles.full_name
  final String phoneNumber;    // → patient_profiles.phone_number
  final String email;          // → users.email
  final DateTime dateOfBirth;  // → patient_profiles.date_of_birth
  final String nationalId;     // captured for identity; not in schema → send as metadata or ignore after verification
  final String password;       // → hashed on backend → users.password_hash

  const SignupEntity({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.dateOfBirth,
    required this.nationalId,
    required this.password,
  });
}

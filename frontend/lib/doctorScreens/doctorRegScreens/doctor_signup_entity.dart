// ─────────────────────────────────────────────────────────────
// DOMAIN LAYER → Doctor Signup Entity
//
// WHY a separate entity from DoctorEntity (login response)?
// DoctorEntity models what comes BACK from the server after
// authentication (id, token, bio, experienceYears…).
// DoctorSignupEntity models what goes TO the server during
// registration — a completely different set of fields.
// Merging them would violate Single Responsibility.
//
// Database dual-insert alignment (FINAL_DIAGRAM):
//   INSERT INTO users (email, password_hash, role_id=2)
//     → returns user_id
//   INSERT INTO doctor_profiles (
//     user_id, full_name, phone_number, specialization,
//     license_number  ← stored as identity/verification field
//   )
//
// Fields collected on this screen (Step 1 of 2):
//   fullName       → doctor_profiles.full_name
//   phoneNumber    → doctor_profiles.phone_number
//   email          → users.email
//   specialization → doctor_profiles.specialization
//   licenseNumber  → verification field (sent to backend)
//   password       → hashed by backend → users.password_hash
// ─────────────────────────────────────────────────────────────

class DoctorSignupEntity {
  final String fullName;        // doctor_profiles.full_name
  final String phoneNumber;     // doctor_profiles.phone_number
  final String email;           // users.email
  final String specialization;  // doctor_profiles.specialization
  final String licenseNumber;   // identity/license verification
  final String password;        // → users.password_hash (hashed server-side)

  const DoctorSignupEntity({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.specialization,
    required this.licenseNumber,
    required this.password,
  });
}

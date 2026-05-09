// ─────────────────────────────────────────────────────────────
// DOMAIN LAYER → Doctor Entity
//
// Database alignment (FINAL_DIAGRAM):
//   users            → id, email, role_id=2, is_active
//   doctor_profiles  → full_name, specialization,
//                      experience_years, consultation_fee, bio
//
// WHY a DoctorEntity separate from UserEntity?
// A logged-in doctor needs specialization + consultation_fee
// for their home dashboard.  UserEntity only carries patient-
// profile fields.  Separation of Concerns: each entity models
// exactly what its consumer (the doctor home screen) needs.
//
// roles table: id=1 → 'patient', id=2 → 'doctor'
// ─────────────────────────────────────────────────────────────

class DoctorEntity {
  final int id;                  // users.id
  final String email;            // users.email
  final String fullName;         // doctor_profiles.full_name
  final String specialization;   // doctor_profiles.specialization
  final int experienceYears;     // doctor_profiles.experience_years
  final double consultationFee;  // doctor_profiles.consultation_fee
  final String bio;              // doctor_profiles.bio
  final int roleId;              // users.role_id  (must be 2)
  final bool isActive;           // users.is_active
  final String token;            // JWT

  const DoctorEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.specialization,
    required this.experienceYears,
    required this.consultationFee,
    required this.bio,
    required this.roleId,
    required this.isActive,
    required this.token,
  });
}

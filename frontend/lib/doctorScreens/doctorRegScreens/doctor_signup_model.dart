
// ─────────────────────────────────────────────────────────────
// DATA LAYER → Doctor Signup Model
//
// WHY separate Model from Entity?
// Entity is pure Dart (Domain layer, no JSON knowledge).
// Model extends it and adds toJson() so the Data layer
// can serialise it for the HTTP POST.
//
// Expected API body  POST /auth/register/doctor:
// {
//   "email":          users.email,
//   "password":       plain text → backend hashes to password_hash,
//   "role":           "doctor"   → backend resolves role_id = 2,
//   "full_name":      doctor_profiles.full_name,
//   "phone_number":   doctor_profiles.phone_number,
//   "specialization": doctor_profiles.specialization,
//   "license_number": verification field
// }
// ─────────────────────────────────────────────────────────────

import 'doctor_signup_entity.dart';

class DoctorSignupModel extends DoctorSignupEntity {
  const DoctorSignupModel({
    required super.fullName,
    required super.phoneNumber,
    required super.email,
    required super.specialization,
    required super.licenseNumber,
    required super.password,
  });

  Map<String, dynamic> toJson() => {
    'email':          email,
    'password':       password,
    'role':           'doctor',
    'full_name':      fullName,
    'phone_number':   phoneNumber,
    'specialization': specialization,
    'license_number': licenseNumber,
  };

  factory DoctorSignupModel.fromEntity(DoctorSignupEntity entity) {
    return DoctorSignupModel(
      fullName:       entity.fullName,
      phoneNumber:    entity.phoneNumber,
      email:          entity.email,
      specialization: entity.specialization,
      licenseNumber:  entity.licenseNumber,
      password:       entity.password,
    );
  }
}

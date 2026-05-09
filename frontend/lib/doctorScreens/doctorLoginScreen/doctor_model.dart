
// ─────────────────────────────────────────────────────────────
// DATA LAYER → Doctor Model
//
// Expected API response body:
// {
//   "token": "eyJhbGciOi...",
//   "user": {
//     "id":        2,
//     "email":     "dr.ahmed@clinic.com",
//     "role_id":   2,          ← users.role_id  (must = kDoctorRoleId)
//     "is_active": true,       ← users.is_active
//     "profile": {
//       "full_name":        "Dr. Ahmed Belkacem",   ← doctor_profiles
//       "specialization":   "Cardiologist",
//       "experience_years": 12,
//       "consultation_fee": 2500.0,
//       "bio":              "Specialist in..."
//     }
//   }
// }
//
// WHY separate from DoctorEntity?
// Entity = pure Dart (Domain).  Model = JSON-aware (Data).
// fromJson lives here; Entity has zero knowledge of JSON.
// ─────────────────────────────────────────────────────────────

import 'doctor_entity.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.specialization,
    required super.experienceYears,
    required super.consultationFee,
    required super.bio,
    required super.roleId,
    required super.isActive,
    required super.token,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    final user    = json['user'] as Map<String, dynamic>;
    // profile sub-object maps to doctor_profiles table
    final profile = user['profile'] as Map<String, dynamic>? ?? {};

    return DoctorModel(
      id:              (user['id'] as num).toInt(),
      email:           user['email'] as String,
      roleId:          (user['role_id'] as num).toInt(),
      isActive:        user['is_active'] as bool? ?? true,
      token:           json['token'] as String,
      fullName:        profile['full_name']        as String? ?? '',
      specialization:  profile['specialization']   as String? ?? '',
      experienceYears: (profile['experience_years'] as num?)?.toInt() ?? 0,
      consultationFee: (profile['consultation_fee'] as num?)?.toDouble() ?? 0.0,
      bio:             profile['bio']              as String? ?? '',
    );
  }

  /// Serialise for local caching in SharedPreferences.
  Map<String, dynamic> toJson() => {
    'token': token,
    'user': {
      'id':        id,
      'email':     email,
      'role_id':   roleId,
      'is_active': isActive,
      'profile': {
        'full_name':        fullName,
        'specialization':   specialization,
        'experience_years': experienceYears,
        'consultation_fee': consultationFee,
        'bio':              bio,
      },
    },
  };
}

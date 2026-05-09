
// ─────────────────────────────────────────────────────────────
// DATA LAYER → User Model
//
// WHY a Model separate from the Entity?
// The Entity is a pure Dart object with no JSON awareness.
// The Model adds fromJson() to parse the server response.
//
// Expected API response body (from backend docs):
// {
//   "token":   "eyJhbGciOi...",
//   "user": {
//     "id":       1,
//     "email":    "ali@email.com",
//     "role_id":  1,              ← from users table
//     "is_active": true,          ← from users table
//     "profile": {
//       "full_name":    "Ali Ben...",   ← patient_profiles.full_name
//       "phone_number": "+213551234567" ← patient_profiles.phone_number
//     }
//   }
// }
// ─────────────────────────────────────────────────────────────

import 'package:shifa/patientScreens/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.phoneNumber,
    required super.roleId,
    required super.isActive,
    required super.token,
  });

  /// Parses the backend JSON response into a UserModel.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // The profile sub-object maps to patient_profiles table.
    final profile = json['user']['profile'] as Map<String, dynamic>? ?? {};

    return UserModel(
      id:          (json['user']['id'] as num).toInt(),
      email:       json['user']['email'] as String,
      roleId:      (json['user']['role_id'] as num).toInt(),
      isActive:    json['user']['is_active'] as bool? ?? true,
      fullName:    profile['full_name'] as String? ?? '',
      phoneNumber: profile['phone_number'] as String? ?? '',
      token:       json['token'] as String,
    );
  }

  /// Converts back to JSON (useful for caching the user locally
  /// in SharedPreferences after login).
  Map<String, dynamic> toJson() => {
    'token': token,
    'user': {
      'id': id,
      'email': email,
      'role_id': roleId,
      'is_active': isActive,
      'profile': {
        'full_name': fullName,
        'phone_number': phoneNumber,
      },
    },
  };
}

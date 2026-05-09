
// ─────────────────────────────────────────────────────────────
// DATA LAYER → Model
//
// WHY a separate Model from Entity?
// The Entity is a pure Dart object with no JSON awareness.
// The Model extends it and adds toJson() so the Data layer
// can serialise it for the HTTP call.
//
// If the API changes its field names, only this file changes –
// the Domain and Presentation layers are unaffected.
// ─────────────────────────────────────────────────────────────

import 'package:shifa/PatientRegister/signup_entity.dart';

class SignupModel extends SignupEntity {
  const SignupModel({
    required super.fullName,
    required super.phoneNumber,
    required super.email,
    required super.dateOfBirth,
    required super.nationalId,
    required super.password,
  });

  /// Converts to the JSON body expected by the backend.
  ///
  /// Backend dual-insert logic:
  ///  POST /auth/register/patient
  ///  Body:
  ///  {
  ///    "email":         users.email,
  ///    "password":      users.password_hash (plain; backend hashes it),
  ///    "role":          "patient",           (backend resolves role_id),
  ///    "full_name":     patient_profiles.full_name,
  ///    "phone_number":  patient_profiles.phone_number,
  ///    "date_of_birth": patient_profiles.date_of_birth  (ISO 8601 date),
  ///    "national_id":   for identity verification
  ///  }
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'role': 'patient',
      'full_name': fullName,
      'phone_number': phoneNumber,
      // Format as SQL date string YYYY-MM-DD
      'date_of_birth':
          '${dateOfBirth.year.toString().padLeft(4, '0')}'
          '-${dateOfBirth.month.toString().padLeft(2, '0')}'
          '-${dateOfBirth.day.toString().padLeft(2, '0')}',
      'national_id': nationalId,
    };
  }

  /// Factory constructor to create a Model from an Entity.
  /// Used when the BLoC passes an Entity to the repository.
  factory SignupModel.fromEntity(SignupEntity entity) {
    return SignupModel(
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      email: entity.email,
      dateOfBirth: entity.dateOfBirth,
      nationalId: entity.nationalId,
      password: entity.password,
    );
  }
}


// ─────────────────────────────────────────────────────────────
// DOMAIN LAYER → Doctor Login Repository Interface
//
// WHY a separate DoctorLoginRepository from LoginRepository?
// SOLID – Interface Segregation Principle:
// Patient login returns UserEntity (with patient_profiles data).
// Doctor login returns DoctorEntity (with doctor_profiles data).
// Merging them into one repository would force both to know
// about fields they don't use.  Keeping them separate means
// each is minimal, focused, and independently testable.
//
// The concrete implementation lives in the Data layer and is
// injected at runtime — the Domain layer stays framework-free.
// ─────────────────────────────────────────────────────────────

import 'doctor_entity.dart';

abstract class DoctorLoginRepository {
  /// Authenticates a doctor by email + password.
  ///
  /// On success  → returns [DoctorEntity] populated from
  ///               users JOIN doctor_profiles.
  /// On failure  → throws [Exception] with a user-readable
  ///               message (wrong credentials, account inactive,
  ///               wrong role, etc.).
  Future<DoctorEntity> loginDoctor({
    required String email,
    required String password,
  });
}

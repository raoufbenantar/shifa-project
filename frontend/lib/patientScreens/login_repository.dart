

// ─────────────────────────────────────────────────────────────
// DOMAIN LAYER → Login Repository Interface
//
// WHY a separate LoginRepository from SignupRepository?
// Single Responsibility Principle: signup and login are
// different business operations with different inputs and
// outputs.  Keeping them separate means each can evolve
// independently (e.g. login might add biometrics later).
//
// WHY abstract here?
// The Domain layer must NOT depend on http, dio, or any
// framework package.  The concrete implementation lives in
// the Data layer and is injected at runtime.
// ─────────────────────────────────────────────────────────────

import 'package:shifa/patientScreens/user_entity.dart';

abstract class LoginRepository {
  /// Authenticates a patient by email + password.
  ///
  /// On success  → returns [UserEntity] (never null).
  /// On failure  → throws an [Exception] with a message
  ///               that the BLoC will surface to the user.
  ///
  /// The implementation MUST validate that the returned
  /// user's role_id corresponds to the 'patient' role
  /// (role_id = 1) before resolving, to prevent a doctor
  /// account from logging in through the patient screen.
  Future<UserEntity> loginPatient({
    required String email,
    required String password,
  });
}

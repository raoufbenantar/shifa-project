
// ─────────────────────────────────────────────────────────────
// DOMAIN LAYER → Repository Interface (Abstract Contract)
//
// WHY abstract here and concrete in the data layer?
// The Domain layer must NOT depend on HTTP, databases or any
// external package.  We define WHAT the repository does (the
// contract) here.  The Data layer provides the HOW (the real
// HTTP call / mock).  This means we can swap the data source
// (mock → real API → different API) without touching Domain
// or Presentation layers at all.
// ─────────────────────────────────────────────────────────────

import 'package:shifa/PatientRegister/signup_entity.dart';

abstract class SignupRepository {
  /// Registers a new patient.
  /// Returns null on success, or an error message string on failure.
  Future<String?> registerPatient(SignupEntity entity);
}

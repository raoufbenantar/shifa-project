
// ─────────────────────────────────────────────────────────────
// DOMAIN LAYER → Doctor Signup Repository Interface
//
// WHY abstract here?
// Dependency Inversion Principle (D in SOLID):
// The Use Case depends on this abstraction, never on a
// concrete HTTP class.  Swapping mock → real API only
// requires creating a new impl and injecting it — zero
// changes to Domain or Presentation.
// ─────────────────────────────────────────────────────────────

import 'doctor_signup_entity.dart';

abstract class DoctorSignupRepository {
  /// Registers a new doctor account.
  ///
  /// Returns null on success.
  /// Returns a non-null error String on failure.
  Future<String?> registerDoctor(DoctorSignupEntity entity);
}



// ─────────────────────────────────────────────────────────────
// DOMAIN LAYER → Register Doctor Use Case
//
// WHY a dedicated Use Case?
// The Use Case owns every business rule for "registering a
// doctor".  Rules live here — not in the BLoC, not in the UI.
//
// Rules enforced:
//   1. Full name must not be empty.
//   2. Phone must match Algerian format (+213XXXXXXXXX).
//   3. Email must be a valid format.
//   4. Specialization must not be empty.
//   5. License number must not be empty (server verifies it).
//   6. Password must be ≥ 8 characters.
//
// If rules change (e.g. add phone-number blacklist), only this
// file changes.  BLoC and UI remain untouched.
// ─────────────────────────────────────────────────────────────

import 'doctor_signup_entity.dart';
import 'doctor_signup_repository.dart';

class RegisterDoctorUseCase {
  final DoctorSignupRepository _repository;

  // Constructor injection — testable with a mock repository.
  const RegisterDoctorUseCase(this._repository);

  /// Validates fields then calls the repository.
  /// Returns null on success, error message on failure.
  Future<String?> call(DoctorSignupEntity entity) async {
    // ── Rule 1: Full name ─────────────────────────────────
    if (entity.fullName.trim().isEmpty) {
      return 'Full name is required.';
    }

    // ── Rule 2: Phone format (Algerian +213) ──────────────
    final cleanPhone = entity.phoneNumber.replaceAll(' ', '');
    if (!RegExp(r'^\+213\d{9}$').hasMatch(cleanPhone)) {
      return 'Enter a valid Algerian number (+213XXXXXXXXX).';
    }

    // ── Rule 3: Email format ──────────────────────────────
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(entity.email.trim())) {
      return 'Enter a valid email address.';
    }

    // ── Rule 4: Specialization ────────────────────────────
    if (entity.specialization.trim().isEmpty) {
      return 'Specialization is required.';
    }

    // ── Rule 5: License number ────────────────────────────
    if (entity.licenseNumber.trim().isEmpty) {
      return 'License number is required.';
    }

    // ── Rule 6: Password minimum length ──────────────────
    if (entity.password.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    // ── Delegate to repository ────────────────────────────
    return _repository.registerDoctor(entity);
  }
}

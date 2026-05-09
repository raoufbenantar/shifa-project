

// ─────────────────────────────────────────────────────────────
// DOMAIN LAYER → Doctor Login Use Case
//
// Business rules that live here (not in the BLoC, not in UI):
//
//   Rule 1 – Email must be a valid format before network call.
//   Rule 2 – Password ≥ 8 characters.
//   Rule 3 – Returned user must have role_id = 2 (doctor).
//             If a patient tries to log in through the doctor
//             screen, this rule blocks them here — the network
//             call still returns a user but the use case rejects
//             it before the BLoC sees it.
//   Rule 4 – Account must be active (users.is_active = true).
//
// WHY 4 rules in the Use Case and not in the BLoC?
// The BLoC is a Presentation concern.  If tomorrow we add a
// CLI tool or another client, it reuses the Use Case and gets
// all rules for free without touching BLoC or UI.
// ─────────────────────────────────────────────────────────────

// Doctor role_id as defined in the `roles` table.
// roles.id = 2, roles.name = 'doctor'  (from FINAL_DIAGRAM)
import 'doctor_entity.dart';
import 'doctor_login_repository.dart';

const int kDoctorRoleId = 2;

class DoctorLoginUseCase {
  final DoctorLoginRepository _repository;

  const DoctorLoginUseCase(this._repository);

  Future<DoctorEntity> call({
    required String email,
    required String password,
  }) async {
    // ── Rule 1: Email format ──────────────────────────────
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.trim())) {
      throw Exception('Please enter a valid email address.');
    }

    // ── Rule 2: Password minimum length ──────────────────
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters.');
    }

    // ── Network call ──────────────────────────────────────
    final doctor = await _repository.loginDoctor(
      email: email.trim(),
      password: password,
    );

    // ── Rule 3: Role enforcement ──────────────────────────
    // This is the critical role-based navigation guard.
    // A patient account MUST NOT access the doctor dashboard.
    if (doctor.roleId != kDoctorRoleId) {
      throw Exception(
        'This account is not registered as a doctor.\n'
        'Please use the Patient login screen.',
      );
    }

    // ── Rule 4: Active account ────────────────────────────
    if (!doctor.isActive) {
      throw Exception(
        'Your doctor account has been deactivated.\n'
        'Please contact the Shifa support team.',
      );
    }

    return doctor;
  }
}

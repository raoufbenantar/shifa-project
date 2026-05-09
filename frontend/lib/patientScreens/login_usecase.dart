

// ─────────────────────────────────────────────────────────────
// DOMAIN LAYER → Login Use Case
//
// WHY a Use Case class?
// The Use Case owns all business rules for "logging in a
// patient".  Rules that belong here (not in the BLoC,
// not in the UI):
//
//   Rule 1 – Email must be a valid format before hitting
//            the network (saves an unnecessary API call).
//   Rule 2 – Password must be at least 8 characters.
//   Rule 3 – The authenticated user MUST have role_id
//            matching 'patient'.  If a doctor tries to
//            log in through this screen the use case
//            throws an error before the app proceeds.
//
// The BLoC calls this use case — it never calls the
// repository directly.  This keeps the BLoC thin and
// the business rules in one place.
// ─────────────────────────────────────────────────────────────

// Patient role_id value as defined in the `roles` table.
// roles.id = 1, roles.name = 'patient'  (from FINAL_DIAGRAM)
import 'package:shifa/patientScreens/user_entity.dart';

import 'login_repository.dart';

const int kPatientRoleId = 1;

class LoginUseCase {
  final LoginRepository _repository;

  // Constructor injection — allows mock injection in tests.
  const LoginUseCase(this._repository);

  /// Executes the patient login flow.
  ///
  /// Throws [Exception] with a human-readable message on
  /// any validation or server error.
  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    // ── Rule 1: Email format ──────────────────────────────
    // WHY validate here and not only in the UI?
    // The UI can change; the Domain rule must always hold.
    // This also prevents an unnecessary network request.
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.trim())) {
      throw Exception('Please enter a valid email address.');
    }

    // ── Rule 2: Password minimum length ──────────────────
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters.');
    }

    // ── Call the repository (network / cache) ─────────────
    final user = await _repository.loginPatient(
      email: email.trim(),
      password: password,
    );

    // ── Rule 3: Role enforcement ──────────────────────────
    // A doctor account must not be able to log in through
    // the patient screen.  We check the role_id returned
    // by the backend against the known patient role value.
    if (user.roleId != kPatientRoleId) {
      throw Exception(
        'This account is not registered as a patient.\n'
        'Please use the Doctor login screen.',
      );
    }

    // ── Rule 4: Account active check ─────────────────────
    if (!user.isActive) {
      throw Exception(
        'Your account has been deactivated.\n'
        'Please contact support.',
      );
    }

    return user;
  }
}

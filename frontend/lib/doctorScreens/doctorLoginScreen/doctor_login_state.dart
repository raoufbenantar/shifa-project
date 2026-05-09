
// ─────────────────────────────────────────────────────────────
// PRESENTATION LAYER → Doctor Login States
//
// 4 states mirror the login lifecycle:
//   Initial  → screen opened, no action yet
//   Loading  → API call in progress → spinner in button
//   Success  → authenticated doctor → navigate to dashboard
//   Failure  → wrong creds / role / inactive → SnackBar
//
// WHY carry DoctorEntity in Success?
// The doctor dashboard needs specialization + consultation_fee
// for the greeting and summary cards.  Passing it through the
// state avoids a second API call after navigation.
// ─────────────────────────────────────────────────────────────

import 'doctor_entity.dart';

abstract class DoctorLoginState {
  const DoctorLoginState();
}

class DoctorLoginInitial extends DoctorLoginState {
  const DoctorLoginInitial();
}

/// API call in flight — "Sign in" button shows spinner.
class DoctorLoginLoading extends DoctorLoginState {
  const DoctorLoginLoading();
}

/// Authentication succeeded.
/// [doctor] is passed to the Doctor Home Screen.
class DoctorLoginSuccess extends DoctorLoginState {
  final DoctorEntity doctor;
  const DoctorLoginSuccess(this.doctor);
}

/// Authentication failed.
/// [message] is shown in a SnackBar.
class DoctorLoginFailure extends DoctorLoginState {
  final String message;
  const DoctorLoginFailure(this.message);
}

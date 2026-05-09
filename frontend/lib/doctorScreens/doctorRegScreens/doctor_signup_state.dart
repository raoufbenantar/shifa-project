// ─────────────────────────────────────────────────────────────
// PRESENTATION → Doctor Signup BLoC States
//
// 4 states covering the full registration lifecycle:
//
//   Initial  → screen first opened
//   Loading  → API call in progress → spinner inside "Continue"
//   Success  → registered → navigate away
//   Failure  → API / validation error → SnackBar message
// ─────────────────────────────────────────────────────────────

abstract class DoctorSignupState {
  const DoctorSignupState();
}

class DoctorSignupInitial extends DoctorSignupState {
  const DoctorSignupInitial();
}

/// "Continue" button shows CircularProgressIndicator.
class DoctorSignupLoading extends DoctorSignupState {
  const DoctorSignupLoading();
}

/// Registration successful — navigate to Step 2 or Login.
class DoctorSignupSuccess extends DoctorSignupState {
  const DoctorSignupSuccess();
}

/// Something went wrong.
/// [message] is surfaced via SnackBar.
class DoctorSignupFailure extends DoctorSignupState {
  final String message;
  const DoctorSignupFailure(this.message);
}

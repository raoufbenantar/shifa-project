// ─────────────────────────────────────────────────────────────
// PRESENTATION LAYER → BLoC States
//
// WHY 4 distinct states?
//   SignupInitial  → screen first renders, no action yet
//   SignupLoading  → API call in progress → show spinner in btn
//   SignupSuccess  → registration done → navigate away
//   SignupFailure  → API / validation error → show message
//
// The UI rebuilds only when the state changes, so the
// BlocBuilder only does work when it has to.
// ─────────────────────────────────────────────────────────────

abstract class SignupState {
  const SignupState();
}

/// Default state – screen just loaded.
class SignupInitial extends SignupState {
  const SignupInitial();
}

/// API call in progress.
/// The button shows a CircularProgressIndicator.
class SignupLoading extends SignupState {
  const SignupLoading();
}

/// Registration completed successfully.
/// The screen navigates to login (or home).
class SignupSuccess extends SignupState {
  const SignupSuccess();
}

/// Something went wrong.
/// [message] is shown in a SnackBar.
class SignupFailure extends SignupState {
  final String message;
  const SignupFailure(this.message);
}

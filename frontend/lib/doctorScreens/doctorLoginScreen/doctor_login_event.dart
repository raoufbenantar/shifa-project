// ─────────────────────────────────────────────────────────────
// PRESENTATION LAYER → Doctor Login Events
//
// An Event represents a user intention dispatched by the UI.
// The BLoC reacts to events and emits states.
// ─────────────────────────────────────────────────────────────

abstract class DoctorLoginEvent {
  const DoctorLoginEvent();
}

/// Fired when the doctor taps the "Sign in" button.
/// Carries email + password read from the form controllers.
class DoctorLoginSubmitted extends DoctorLoginEvent {
  final String email;
  final String password;

  const DoctorLoginSubmitted({
    required this.email,
    required this.password,
  });
}

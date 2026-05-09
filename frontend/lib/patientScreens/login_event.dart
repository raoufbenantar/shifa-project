// ─────────────────────────────────────────────────────────────
// PRESENTATION LAYER → Login BLoC Events
//
// An Event = a user intention (something that happened in UI).
//
// Current events:
//   LoginSubmitted   → user tapped "Sign in"
//
// Future events (add without touching existing code):
//   LoginGoogleTapped
//   LoginAppleTapped
//   LoginForgotPasswordTapped
// ─────────────────────────────────────────────────────────────

abstract class LoginEvent {
  const LoginEvent();
}

/// Fired when the user taps the "Sign in" button.
/// Carries email + password read from the form fields.
class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  const LoginSubmitted({
    required this.email,
    required this.password,
  });
}

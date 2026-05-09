
// ─────────────────────────────────────────────────────────────
// PRESENTATION LAYER → Login BLoC States
//
// 4 states mirror the login lifecycle exactly:
//
//   LoginInitial  → screen just opened, no action yet
//   LoginLoading  → API call in progress → spinner in button
//   LoginSuccess  → authenticated → navigate to Home
//   LoginFailure  → wrong creds / server error → SnackBar
//
// WHY carry UserEntity in LoginSuccess?
// The Home screen needs the user's name for the greeting
// ("Welcome back, Ali").  Passing it through the state
// avoids a second API call after navigation.
// ─────────────────────────────────────────────────────────────

import 'package:shifa/patientScreens/user_entity.dart';

abstract class LoginState {
  const LoginState();
}

/// Default — screen just loaded.
class LoginInitial extends LoginState {
  const LoginInitial();
}

/// Network call in flight.
/// The "Sign in" button shows CircularProgressIndicator.
class LoginLoading extends LoginState {
  const LoginLoading();
}

/// Authentication succeeded.
/// [user] carries the logged-in patient's data.
class LoginSuccess extends LoginState {
  final UserEntity user;
  const LoginSuccess(this.user);
}

/// Authentication failed.
/// [message] is shown in a SnackBar.
class LoginFailure extends LoginState {
  final String message;
  const LoginFailure(this.message);
}

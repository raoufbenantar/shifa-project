import 'package:shifa/PatientRegister/signup_entity.dart';


// ─────────────────────────────────────────────────────────────
// PRESENTATION LAYER → BLoC Events
//
// WHY sealed/abstract events?
// An Event represents a user intention (what happened).
// Using an abstract base class lets the BLoC's
// `on<SignupEvent>` handler switch on concrete subtypes
// with exhaustive coverage.
//
// We only have ONE event right now:
//   SignupSubmitted → user tapped "create account"
//
// Future events could be:
//   SignupFieldChanged → for real-time validation
// ─────────────────────────────────────────────────────────────

abstract class SignupEvent {
  const SignupEvent();
}

/// Fired when the user taps "create account".
/// Carries the fully-formed Entity so the BLoC
/// passes it directly to the Use Case.
class SignupSubmitted extends SignupEvent {
  final SignupEntity entity;
  const SignupSubmitted(this.entity);
}

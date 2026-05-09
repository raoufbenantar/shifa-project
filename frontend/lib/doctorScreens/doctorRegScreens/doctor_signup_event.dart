import 'doctor_signup_entity.dart';

// ─────────────────────────────────────────────────────────────
// PRESENTATION → Doctor Signup BLoC Events
//
// An Event = a user intention dispatched from the UI.
// The BLoC handler converts it into a State.
// ─────────────────────────────────────────────────────────────

abstract class DoctorSignupEvent {
  const DoctorSignupEvent();
}

/// Fired when the doctor taps "Continue".
/// Carries the fully assembled Entity so the BLoC passes it
/// directly to the Use Case — no field reading inside the BLoC.
class DoctorSignupSubmitted extends DoctorSignupEvent {
  final DoctorSignupEntity entity;
  const DoctorSignupSubmitted(this.entity);
}

// ─────────────────────────────────────────────
// WHY an enum?
// The backend has a `roles` table with "patient"
// and "doctor" values.  Using a Dart enum means
// the compiler catches typos at compile time and
// we can use exhaustive switch statements safely.
// ─────────────────────────────────────────────

enum UserRole {
  patient,
  doctor;

  // Convenience helper that maps the enum value
  // to the exact string stored in the database
  // `roles.name` column.
  String get dbValue {
    switch (this) {
      case UserRole.patient:
        return 'patient';
      case UserRole.doctor:
        return 'doctor';
    }
  }
}

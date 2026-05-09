import 'package:shifa/PatientRegister/signup_entity.dart';
import 'package:shifa/PatientRegister/signup_repository.dart';



// ─────────────────────────────────────────────────────────────
// DOMAIN LAYER → Use Case
//
// WHY a Use Case class?
// A Use Case encapsulates a single business action.
// "Register a patient" is one business action.
//
// Benefits:
//  • The BLoC calls the Use Case – it never calls the
//    repository directly.  This means the BLoC stays thin:
//    it only converts Events → States.
//  • If registration rules change (e.g. add email verification
//    step), we only modify this class, not the BLoC.
//  • Unit-testable in complete isolation.
// ─────────────────────────────────────────────────────────────

class RegisterPatientUseCase {
  final SignupRepository _repository;

  // WHY constructor injection?
  // We pass the repository in rather than creating it inside
  // the class.  This is Dependency Inversion (the D in SOLID)
  // and makes the use case testable with a mock repository.
  const RegisterPatientUseCase(this._repository);

  /// Executes the patient registration.
  /// Returns null on success, error message on failure.
  Future<String?> call(SignupEntity entity) {
    return _repository.registerPatient(entity);
  }
}

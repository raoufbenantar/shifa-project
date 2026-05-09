import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shifa/PatientRegister/register_patient_usecase.dart';

import 'signup_event.dart';
import 'signup_state.dart';

// ─────────────────────────────────────────────────────────────
// PRESENTATION LAYER → BLoC
//
// WHY BLoC and not Provider/Riverpod/setState?
// BLoC enforces a strict one-directional data flow:
//   UI dispatches Event → BLoC emits State → UI rebuilds
// This makes async flows (loading → success/failure)
// explicit, traceable, and easy to unit-test.
//
// The BLoC:
//  • Receives   : SignupEvent   (user actions)
//  • Emits      : SignupState   (what the UI should show)
//  • Depends on : RegisterPatientUseCase (Domain layer only)
//  • NEVER calls the repository or HTTP directly
// ─────────────────────────────────────────────────────────────

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final RegisterPatientUseCase _registerPatientUseCase;

  SignupBloc(this._registerPatientUseCase) : super(const SignupInitial()) {
    // Register handler for SignupSubmitted event.
    // WHY `on<T>` pattern?
    // flutter_bloc ≥ 8 uses this instead of mapEventToState.
    // It's more composable and avoids yield-in-async issues.
    on<SignupSubmitted>(_onSignupSubmitted);
  }

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    // Step 1: Tell the UI to show the loading spinner
    emit(const SignupLoading());

    // Step 2: Delegate ALL business logic to the Use Case.
    // The BLoC knows nothing about HTTP, JSON, or database.
    final error = await _registerPatientUseCase(event.entity);

    // Step 3: Emit the outcome state
    if (error == null) {
      // null from the use case means success
      emit(const SignupSuccess());
    } else {
      emit(SignupFailure(error));
    }
  }
}

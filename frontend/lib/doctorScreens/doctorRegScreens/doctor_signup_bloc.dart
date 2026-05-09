import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shifa/doctorScreens/doctorRegScreens/register_doctor_usecase.dart';

import 'doctor_signup_event.dart';
import 'doctor_signup_state.dart';

// ─────────────────────────────────────────────────────────────
// PRESENTATION → DoctorSignupBloc
//
// Responsibility: Event → UseCase → State
//
// The BLoC:
//   • Receives  DoctorSignupEvent (user tapped Continue)
//   • Delegates ALL logic to RegisterDoctorUseCase
//   • Emits     DoctorSignupState (loading / success / failure)
//
// It never reads controllers, touches HTTP, or calls Navigator.
// This makes it fully unit-testable with bloc_test.
// ─────────────────────────────────────────────────────────────

class DoctorSignupBloc
    extends Bloc<DoctorSignupEvent, DoctorSignupState> {
  final RegisterDoctorUseCase _registerDoctorUseCase;

  DoctorSignupBloc(this._registerDoctorUseCase)
      : super(const DoctorSignupInitial()) {
    on<DoctorSignupSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    DoctorSignupSubmitted event,
    Emitter<DoctorSignupState> emit,
  ) async {
    // 1. Show spinner in the "Continue" button
    emit(const DoctorSignupLoading());

    // 2. Use Case runs all business rules + calls repository.
    //    Returns null on success, error string on failure.
    final error = await _registerDoctorUseCase(event.entity);

    // 3. Emit outcome
    if (error == null) {
      emit(const DoctorSignupSuccess());
    } else {
      emit(DoctorSignupFailure(error));
    }
  }
}

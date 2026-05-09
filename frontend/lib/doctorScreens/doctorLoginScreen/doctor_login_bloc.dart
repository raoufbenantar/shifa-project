import 'package:flutter_bloc/flutter_bloc.dart';

import 'doctor_login_event.dart';
import 'doctor_login_state.dart';
import 'doctor_login_usecase.dart';

// ─────────────────────────────────────────────────────────────
// PRESENTATION LAYER → DoctorLoginBloc
//
// Responsibility: Event → Use Case → State
//
// The BLoC NEVER:
//   • reads TextEditingControllers (screen does that)
//   • touches http / json  (data layer does that)
//   • calls Navigator (BlocConsumer listener does that)
//
// This strict separation makes the BLoC unit-testable with
// zero Flutter dependencies — just Dart + bloc_test.
// ─────────────────────────────────────────────────────────────

class DoctorLoginBloc extends Bloc<DoctorLoginEvent, DoctorLoginState> {
  final DoctorLoginUseCase _doctorLoginUseCase;

  DoctorLoginBloc(this._doctorLoginUseCase)
      : super(const DoctorLoginInitial()) {
    on<DoctorLoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    DoctorLoginSubmitted event,
    Emitter<DoctorLoginState> emit,
  ) async {
    // Step 1: show spinner
    emit(const DoctorLoginLoading());

    try {
      // Step 2: delegate all business rules to the Use Case
      // (email validation, password length, role_id check,
      //  is_active check — all happen inside DoctorLoginUseCase)
      final doctor = await _doctorLoginUseCase(
        email: event.email,
        password: event.password,
      );

      // Step 3a: success — carry the DoctorEntity
      emit(DoctorLoginSuccess(doctor));
    } catch (e) {
      // Step 3b: failure — clean readable message
      emit(DoctorLoginFailure(
        e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}

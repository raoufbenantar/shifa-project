import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_event.dart';
import 'login_state.dart';
import 'login_usecase.dart';

// ─────────────────────────────────────────────────────────────
// PRESENTATION LAYER → LoginBloc
//
// Responsibility:
//   Receive LoginEvent → call LoginUseCase → emit LoginState
//
// The BLoC NEVER:
//   • touches http / json
//   • reads TextEditingControllers (the screen does that)
//   • knows about Navigator (the BlocConsumer listener does that)
//
// This makes the BLoC fully unit-testable without a Flutter
// widget tree or a network connection.
// ─────────────────────────────────────────────────────────────

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;

  LoginBloc(this._loginUseCase) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    // Step 1: Tell UI to show the spinner
    emit(const LoginLoading());

    try {
      // Step 2: Execute all business rules via the Use Case.
      // The Use Case validates email format, password length,
      // role_id check, and is_active check — the BLoC just
      // calls and awaits.
      final user = await _loginUseCase(
        email: event.email,
        password: event.password,
      );

      // Step 3a: Success — carry the user entity to the screen
      emit(LoginSuccess(user));
    } catch (e) {
      // Step 3b: Failure — surface a clean message
      emit(LoginFailure(
        e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}

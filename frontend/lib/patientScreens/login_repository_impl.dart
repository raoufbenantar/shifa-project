

// ─────────────────────────────────────────────────────────────
// DATA LAYER → Login Repository Implementation
//
// WHY implement here and not in Domain?
// This class CAN import http packages, models, and data
// sources.  The Domain layer can't — it must stay pure Dart.
// The LoginBloc only ever sees LoginRepository (the abstract
// interface from Domain), never this class directly.
// ─────────────────────────────────────────────────────────────

import 'package:shifa/patientScreens/user_entity.dart';

import 'login_remote_datasource.dart';
import 'login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDataSource _dataSource;

  const LoginRepositoryImpl(this._dataSource);

  @override
  Future<UserEntity> loginPatient({
    required String email,
    required String password,
  }) async {
    try {
      // The data source returns a UserModel (Data layer type).
      // Since UserModel extends UserEntity, we can return it
      // typed as UserEntity — the Domain/BLoC layer only sees
      // the Entity and remains decoupled from the Model.
      return await _dataSource.loginPatient(
        email: email,
        password: password,
      );
    } catch (e) {
      // Re-throw as a clean Exception so the Use Case and
      // BLoC receive consistent error types regardless of
      // whether the error came from the network, JSON parsing,
      // or the mock.
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

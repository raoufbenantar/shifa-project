

// ─────────────────────────────────────────────────────────────
// DATA LAYER → Doctor Login Repository Implementation
//
// This class bridges the Domain contract (abstract interface)
// and the Data source (HTTP / mock).
//
// The DoctorLoginUseCase and DoctorLoginBloc only ever see
// DoctorLoginRepository (the abstract type) — they never know
// this concrete class exists.  This is Dependency Inversion
// (the D in SOLID).
// ─────────────────────────────────────────────────────────────

import 'doctor_entity.dart';
import 'doctor_login_remote_datasource.dart';
import 'doctor_login_repository.dart';

class DoctorLoginRepositoryImpl implements DoctorLoginRepository {
  final DoctorLoginRemoteDataSource _dataSource;

  const DoctorLoginRepositoryImpl(this._dataSource);

  @override
  Future<DoctorEntity> loginDoctor({
    required String email,
    required String password,
  }) async {
    try {
      // DoctorModel extends DoctorEntity so it satisfies
      // the return type without any casting.
      return await _dataSource.loginDoctor(
        email: email,
        password: password,
      );
    } catch (e) {
      // Translate any exception (network, JSON parse, mock)
      // into a clean Exception with a user-readable message.
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

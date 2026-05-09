

// ─────────────────────────────────────────────────────────────
// DATA LAYER → Doctor Signup Repository Implementation
//
// Converts the Domain Entity → Data Model → calls datasource.
// Translates any Exception into a plain String so the Domain
// contract (returning String?) is satisfied.
//
// The BLoC only ever sees DoctorSignupRepository (abstract).
// It never imports this file. Dependency Inversion in action.
// ─────────────────────────────────────────────────────────────

import 'doctor_signup_entity.dart';
import 'doctor_signup_model.dart';
import 'doctor_signup_remote_datasource.dart';
import 'doctor_signup_repository.dart';

class DoctorSignupRepositoryImpl implements DoctorSignupRepository {
  final DoctorSignupRemoteDataSource _dataSource;

  const DoctorSignupRepositoryImpl(this._dataSource);

  @override
  Future<String?> registerDoctor(DoctorSignupEntity entity) async {
    try {
      final model = DoctorSignupModel.fromEntity(entity);
      await _dataSource.registerDoctor(model);
      return null; // null = success
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}

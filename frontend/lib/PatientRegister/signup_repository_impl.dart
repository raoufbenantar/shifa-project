import 'package:shifa/PatientRegister/signup_entity.dart';
import 'package:shifa/PatientRegister/signup_model.dart';
import 'package:shifa/PatientRegister/signup_remote_datasource.dart';
import 'package:shifa/PatientRegister/signup_repository.dart';


// ─────────────────────────────────────────────────────────────
// DATA LAYER → Repository Implementation
//
// WHY implement the Domain interface here?
// This class lives in the Data layer and CAN depend on HTTP
// packages, models, etc.  It converts the Domain Entity into
// a Data Model, calls the data source, and translates any
// exceptions into plain error strings that the Domain
// contract requires.
//
// The BLoC only ever sees SignupRepository (the abstract
// interface) – it never knows this class exists.
// ─────────────────────────────────────────────────────────────

class SignupRepositoryImpl implements SignupRepository {
  final SignupRemoteDataSource _dataSource;

  const SignupRepositoryImpl(this._dataSource);

  @override
  Future<String?> registerPatient(SignupEntity entity) async {
    try {
      // Convert Domain Entity → Data Model for serialisation
      final model = SignupModel.fromEntity(entity);
      await _dataSource.registerPatient(model);
      return null; // null = success
    } catch (e) {
      // Convert any exception into a user-friendly string.
      // The Domain layer only deals in String? – no dart:io
      // or http types leak through.
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}

import 'patient_profile_entity.dart';
import 'patient_profile_remote_datasource.dart';
import 'patient_profile_repository.dart';

class PatientProfileRepositoryImpl implements PatientProfileRepository {
  final PatientProfileRemoteDataSource _dataSource;

  const PatientProfileRepositoryImpl(this._dataSource);

  @override
  Future<PatientProfileEntity> getProfile() async {
    try {
      return await _dataSource.getProfile();
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<PatientProfileEntity> updateProfile(Map<String, dynamic> data) async {
    try {
      return await _dataSource.updateProfile(data);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

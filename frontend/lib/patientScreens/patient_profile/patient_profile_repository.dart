import 'patient_profile_entity.dart';

abstract class PatientProfileRepository {
  Future<PatientProfileEntity> getProfile();
  Future<PatientProfileEntity> updateProfile(Map<String, dynamic> data);
}

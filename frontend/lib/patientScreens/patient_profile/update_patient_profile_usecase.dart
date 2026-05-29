import 'patient_profile_entity.dart';
import 'patient_profile_repository.dart';

class UpdatePatientProfileUseCase {
  final PatientProfileRepository _repository;

  const UpdatePatientProfileUseCase(this._repository);

  Future<PatientProfileEntity> call(Map<String, dynamic> data) async {
    if (data.isEmpty) {
      throw Exception('No fields to update.');
    }
    return await _repository.updateProfile(data);
  }
}

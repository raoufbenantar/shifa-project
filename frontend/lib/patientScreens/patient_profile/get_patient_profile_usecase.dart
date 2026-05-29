import 'patient_profile_entity.dart';
import 'patient_profile_repository.dart';

class GetPatientProfileUseCase {
  final PatientProfileRepository _repository;

  const GetPatientProfileUseCase(this._repository);

  Future<PatientProfileEntity> call() async {
    return await _repository.getProfile();
  }
}

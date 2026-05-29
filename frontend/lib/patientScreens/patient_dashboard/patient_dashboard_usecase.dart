import 'patient_dashboard_entity.dart';
import 'patient_dashboard_repository.dart';

class GetPatientDashboardUseCase {
  final PatientDashboardRepository repository;

  GetPatientDashboardUseCase(this.repository);

  Future<PatientDashboardEntity> call() async {
    return await repository.getPatientDashboard();
  }
}

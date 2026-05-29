import 'patient_dashboard_entity.dart';
import 'patient_dashboard_remote_datasource.dart';
import 'patient_dashboard_repository.dart';

class PatientDashboardRepositoryImpl implements PatientDashboardRepository {
  final PatientDashboardRemoteDataSource remoteDataSource;

  PatientDashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<PatientDashboardEntity> getPatientDashboard() async {
    return await remoteDataSource.getPatientDashboard();
  }
}

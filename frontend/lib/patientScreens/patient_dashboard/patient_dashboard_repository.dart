import 'patient_dashboard_entity.dart';

abstract class PatientDashboardRepository {
  Future<PatientDashboardEntity> getPatientDashboard();
}

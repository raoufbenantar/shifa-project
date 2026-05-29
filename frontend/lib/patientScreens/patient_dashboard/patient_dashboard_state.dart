import 'patient_dashboard_entity.dart';

abstract class PatientDashboardState {}

class PatientDashboardInitial extends PatientDashboardState {}

class PatientDashboardLoading extends PatientDashboardState {}

class PatientDashboardLoaded extends PatientDashboardState {
  final PatientDashboardEntity dashboard;
  PatientDashboardLoaded(this.dashboard);
}

class PatientDashboardError extends PatientDashboardState {
  final String message;
  PatientDashboardError(this.message);
}

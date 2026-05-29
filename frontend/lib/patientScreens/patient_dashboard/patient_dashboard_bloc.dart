import 'package:flutter_bloc/flutter_bloc.dart';
import 'patient_dashboard_event.dart';
import 'patient_dashboard_state.dart';
import 'patient_dashboard_usecase.dart';

class PatientDashboardBloc
    extends Bloc<PatientDashboardEvent, PatientDashboardState> {
  final GetPatientDashboardUseCase useCase;

  PatientDashboardBloc(this.useCase) : super(PatientDashboardInitial()) {
    on<LoadPatientDashboard>(_onLoad);
    on<RefreshPatientDashboard>(_onLoad);
  }

  Future<void> _onLoad(
    PatientDashboardEvent event,
    Emitter<PatientDashboardState> emit,
  ) async {
    emit(PatientDashboardLoading());
    try {
      final dashboard = await useCase();
      emit(PatientDashboardLoaded(dashboard));
    } catch (e) {
      emit(PatientDashboardError(e.toString()));
    }
  }
}

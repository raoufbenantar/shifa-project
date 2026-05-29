import 'package:flutter_bloc/flutter_bloc.dart';
import 'patient_profile_event.dart';
import 'patient_profile_state.dart';
import 'get_patient_profile_usecase.dart';
import 'update_patient_profile_usecase.dart';

class PatientProfileBloc
    extends Bloc<PatientProfileEvent, PatientProfileState> {
  final GetPatientProfileUseCase _getUseCase;
  final UpdatePatientProfileUseCase _updateUseCase;

  PatientProfileBloc(this._getUseCase, this._updateUseCase)
      : super(const PatientProfileInitial()) {
    on<LoadPatientProfile>(_onLoad);
    on<UpdatePatientProfileField>(_onUpdateField);
    on<SavePatientProfile>(_onSave);
    on<ToggleEditMode>(_onToggleEdit);
  }

  Future<void> _onLoad(
    LoadPatientProfile event,
    Emitter<PatientProfileState> emit,
  ) async {
    emit(const PatientProfileLoading());
    try {
      final profile = await _getUseCase();
      emit(PatientProfileLoaded(profile));
    } catch (e) {
      emit(PatientProfileError(
        e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void _onUpdateField(
    UpdatePatientProfileField event,
    Emitter<PatientProfileState> emit,
  ) {
    final current = state;
    if (current is PatientProfileLoaded) {
      final updated = current.profile.copyWith(
        fullName: event.field.name == 'fullName'
            ? event.value
            : current.profile.fullName,
        phoneNumber: event.field.name == 'phoneNumber'
            ? event.value
            : current.profile.phoneNumber,
        nationalId: event.field.name == 'nationalId'
            ? event.value
            : current.profile.nationalId,
        dateOfBirth: event.field.name == 'dateOfBirth'
            ? event.value
            : current.profile.dateOfBirth,
        gender: event.field.name == 'gender'
            ? event.value
            : current.profile.gender,
      );
      emit(PatientProfileLoaded(updated, isEditing: true));
    }
  }

  Future<void> _onSave(
    SavePatientProfile event,
    Emitter<PatientProfileState> emit,
  ) async {
    final current = state;
    if (current is PatientProfileLoaded) {
      emit(PatientProfileSaving(current.profile));
      try {
        final data = <String, dynamic>{
          'full_name': current.profile.fullName,
          'phone_number': current.profile.phoneNumber,
          if (current.profile.nationalId != null)
            'national_id': current.profile.nationalId,
          if (current.profile.dateOfBirth != null)
            'date_of_birth': current.profile.dateOfBirth,
          if (current.profile.gender != null) 'gender': current.profile.gender,
        };
        final updated = await _updateUseCase(data);
        emit(PatientProfileLoaded(updated));
      } catch (e) {
        emit(PatientProfileSaveFailure(
          current.profile,
          e.toString().replaceFirst('Exception: ', ''),
        ));
      }
    }
  }

  void _onToggleEdit(
    ToggleEditMode event,
    Emitter<PatientProfileState> emit,
  ) {
    final current = state;
    if (current is PatientProfileLoaded) {
      emit(PatientProfileLoaded(current.profile, isEditing: event.isEditing));
    }
  }
}

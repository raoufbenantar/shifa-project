import 'patient_profile_entity.dart';

abstract class PatientProfileState {}

class PatientProfileInitial extends PatientProfileState {
  PatientProfileInitial();
}

class PatientProfileLoading extends PatientProfileState {
  PatientProfileLoading();
}

class PatientProfileLoaded extends PatientProfileState {
  final PatientProfileEntity profile;
  final bool isEditing;

  PatientProfileLoaded(this.profile, {this.isEditing = false});
}

class PatientProfileSaving extends PatientProfileState {
  final PatientProfileEntity profile;

  PatientProfileSaving(this.profile);
}

class PatientProfileSaveSuccess extends PatientProfileState {
  final String message;

  PatientProfileSaveSuccess(this.message);
}

class PatientProfileError extends PatientProfileState {
  final String message;

  PatientProfileError(this.message);
}

class PatientProfileSaveFailure extends PatientProfileState {
  final PatientProfileEntity profile;
  final String message;

  PatientProfileSaveFailure(this.profile, this.message);
}

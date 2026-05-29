abstract class PatientProfileEvent {}

class LoadPatientProfile extends PatientProfileEvent {
  LoadPatientProfile();
}

enum ProfileField { fullName, phoneNumber, nationalId, dateOfBirth, gender }

class UpdatePatientProfileField extends PatientProfileEvent {
  final ProfileField field;
  final String value;

  UpdatePatientProfileField(this.field, this.value);
}

class SavePatientProfile extends PatientProfileEvent {
  SavePatientProfile();
}

class ToggleEditMode extends PatientProfileEvent {
  final bool isEditing;

  ToggleEditMode(this.isEditing);
}

abstract class PatientProfileEvent {}

class LoadPatientProfile extends PatientProfileEvent {
  const LoadPatientProfile();
}

enum ProfileField { fullName, phoneNumber, nationalId, dateOfBirth, gender }

class UpdatePatientProfileField extends PatientProfileEvent {
  final ProfileField field;
  final String value;

  const UpdatePatientProfileField(this.field, this.value);
}

class SavePatientProfile extends PatientProfileEvent {
  const SavePatientProfile();
}

class ToggleEditMode extends PatientProfileEvent {
  final bool isEditing;

  const ToggleEditMode(this.isEditing);
}

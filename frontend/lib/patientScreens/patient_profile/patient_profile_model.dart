import 'patient_profile_entity.dart';

class PatientProfileModel extends PatientProfileEntity {
  const PatientProfileModel({
    required super.id,
    required super.fullName,
    required super.phoneNumber,
    super.nationalId,
    super.dateOfBirth,
    super.gender,
    super.email,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      nationalId: json['national_id'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      email: json['user_email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'national_id': nationalId,
      'date_of_birth': dateOfBirth,
      'gender': gender,
    };
  }
}

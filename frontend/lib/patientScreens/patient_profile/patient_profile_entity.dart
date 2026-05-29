class PatientProfileEntity {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String? nationalId;
  final String? dateOfBirth;
  final String? gender;
  final String? email;

  const PatientProfileEntity({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.nationalId,
    this.dateOfBirth,
    this.gender,
    this.email,
  });

  PatientProfileEntity copyWith({
    int? id,
    String? fullName,
    String? phoneNumber,
    String? nationalId,
    String? dateOfBirth,
    String? gender,
    String? email,
  }) {
    return PatientProfileEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nationalId: nationalId ?? this.nationalId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      email: email ?? this.email,
    );
  }
}

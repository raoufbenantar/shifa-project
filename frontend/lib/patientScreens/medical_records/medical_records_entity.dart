class MedicalRecordEntity {
  final int id;
  final String? bloodType;
  final String? allergies;
  final String? medicalHistory;
  final List<ConsultationSummary> consultations;
  final String createdAt;

  const MedicalRecordEntity({
    required this.id,
    this.bloodType,
    this.allergies,
    this.medicalHistory,
    required this.consultations,
    required this.createdAt,
  });
}

class ConsultationSummary {
  final int id;
  final String doctorName;
  final String doctorSpecialization;
  final String consultationDate;
  final String? notes;
  final List<DiagnosisEntity> diagnoses;
  final List<PrescriptionEntity> prescriptions;

  const ConsultationSummary({
    required this.id,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.consultationDate,
    this.notes,
    required this.diagnoses,
    required this.prescriptions,
  });
}

class DiagnosisEntity {
  final int id;
  final String description;

  const DiagnosisEntity({
    required this.id,
    required this.description,
  });
}

class PrescriptionEntity {
  final int id;
  final String medicationName;
  final String dosage;
  final int durationDays;

  const PrescriptionEntity({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.durationDays,
  });
}

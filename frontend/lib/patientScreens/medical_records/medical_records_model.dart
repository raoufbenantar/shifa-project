import 'medical_records_entity.dart';

class MedicalRecordModel extends MedicalRecordEntity {
  const MedicalRecordModel({
    required super.id,
    super.bloodType,
    super.allergies,
    super.medicalHistory,
    required super.consultations,
    required super.createdAt,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'],
      bloodType: json['blood_type'],
      allergies: json['allergies'],
      medicalHistory: json['medical_history'],
      consultations: _parseConsultations(json['consultations']),
      createdAt: json['created_at'] ?? '',
    );
  }

  static List<ConsultationSummary> _parseConsultations(dynamic list) {
    if (list == null) return [];
    return (list as List).map((item) {
      final c = item as Map<String, dynamic>;
      final doctorDetails = c['doctor_details'] as Map<String, dynamic>?;
      return ConsultationSummary(
        id: c['id'],
        doctorName: doctorDetails?['full_name'] ?? 'Unknown',
        doctorSpecialization: doctorDetails?['specialization'] ?? '',
        consultationDate: c['consultation_date'],
        notes: c['notes'],
        diagnoses: _parseDiagnoses(c['diagnoses']),
        prescriptions: _parsePrescriptions(c['prescriptions']),
      );
    }).toList();
  }

  static List<DiagnosisEntity> _parseDiagnoses(dynamic list) {
    if (list == null) return [];
    return (list as List).map((item) {
      final d = item as Map<String, dynamic>;
      return DiagnosisEntity(
        id: d['id'],
        description: d['description'] ?? '',
      );
    }).toList();
  }

  static List<PrescriptionEntity> _parsePrescriptions(dynamic list) {
    if (list == null) return [];
    return (list as List).map((item) {
      final p = item as Map<String, dynamic>;
      final medDetails = p['medication_details'] as Map<String, dynamic>?;
      return PrescriptionEntity(
        id: p['id'],
        medicationName: medDetails?['name'] ?? 'Unknown',
        dosage: p['dosage'] ?? '',
        durationDays: p['duration_days'] ?? 0,
      );
    }).toList();
  }
}

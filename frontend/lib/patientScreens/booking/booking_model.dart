import 'booking_entity.dart';

// ─────────────────────────────────────────────
// JSON ↔ Entity mappers.
// Every model is a simple data class that extends
// its entity and adds a fromJson factory.
// ─────────────────────────────────────────────

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.id,
    required super.fullName,
    required super.specialization,
    required super.experienceYears,
    required super.consultationFee,
    super.bio,
    super.image,
    super.avgRating,
    required super.isActive,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) => DoctorModel(
        id: json['id'] as int,
        fullName: json['full_name'] as String? ?? '',
        specialization: json['specialization'] as String? ?? '',
        experienceYears: json['experience_years'] as int? ?? 0,
        consultationFee: _parseDouble(json['consultation_fee']),
        bio: json['bio'] as String?,
        image: json['image'] as String?,
        avgRating: _parseDouble(json['avg_rating']),
        isActive: json['is_active'] as bool? ?? true,
      );

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

class ClinicModel extends ClinicEntity {
  const ClinicModel({
    required super.id,
    required super.name,
    required super.addressText,
    required super.city,
    super.phoneNumber,
    super.openingHours,
    required super.type,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) => ClinicModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        addressText: json['address_text'] as String? ?? '',
        city: json['city'] as String? ?? '',
        phoneNumber: json['phone_number'] as String?,
        openingHours: json['opening_hours'] as String?,
        type: json['type'] as String? ?? 'private',
      );
}

class DoctorClinicModel extends DoctorClinicEntity {
  const DoctorClinicModel({
    required super.id,
    required super.doctorId,
    required super.clinicId,
    super.clinicDetail,
    required super.startDate,
  });

  factory DoctorClinicModel.fromJson(Map<String, dynamic> json) {
    final clinicDetail = json['clinic_detail'] as Map<String, dynamic>?;
    return DoctorClinicModel(
      id: json['id'] as int,
      doctorId: json['doctor'] as int,
      clinicId: json['clinic'] as int,
      clinicDetail:
          clinicDetail != null ? ClinicModel.fromJson(clinicDetail) : null,
      startDate: DateTime.parse(json['start_date'] as String),
    );
  }
}

class AvailableSlotModel extends AvailableSlotEntity {
  const AvailableSlotModel({
    required super.scheduledDatetime,
    required super.time,
  });

  factory AvailableSlotModel.fromJson(Map<String, dynamic> json) =>
      AvailableSlotModel(
        scheduledDatetime: DateTime.parse(json['scheduled_datetime'] as String),
        time: json['time'] as String? ?? '',
      );
}

class PatientAppointmentModel extends PatientAppointmentEntity {
  const PatientAppointmentModel({
    required super.id,
    required super.patientId,
    required super.doctorId,
    required super.clinicId,
    required super.scheduledDatetime,
    required super.consultationType,
    required super.status,
    super.notes,
    super.doctorDetails,
    super.clinicDetails,
  });

  factory PatientAppointmentModel.fromJson(Map<String, dynamic> json) {
    final doctorDetail = json['doctor_details'] as Map<String, dynamic>?;
    final clinicDetail = json['clinic_details'] as Map<String, dynamic>?;
    return PatientAppointmentModel(
      id: json['id'] as int,
      patientId: json['patient'] as int,
      doctorId: json['doctor'] as int,
      clinicId: json['clinic'] as int,
      scheduledDatetime:
          DateTime.parse(json['scheduled_datetime'] as String),
      consultationType: json['consultation_type'] as String? ?? 'in_person',
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      doctorDetails:
          doctorDetail != null ? DoctorModel.fromJson(doctorDetail) : null,
      clinicDetails:
          clinicDetail != null ? ClinicModel.fromJson(clinicDetail) : null,
    );
  }
}

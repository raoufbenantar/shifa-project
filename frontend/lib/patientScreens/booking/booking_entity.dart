/// Domain entities for the patient appointment booking flow.

class DoctorEntity {
  final int id;
  final String fullName;
  final String specialization;
  final int experienceYears;
  final double consultationFee;
  final String? bio;
  final String? image;
  final double? avgRating;
  final bool isActive;

  const DoctorEntity({
    required this.id,
    required this.fullName,
    required this.specialization,
    required this.experienceYears,
    required this.consultationFee,
    this.bio,
    this.image,
    this.avgRating,
    required this.isActive,
  });
}

class ClinicEntity {
  final int id;
  final String name;
  final String addressText;
  final String city;
  final String? phoneNumber;
  final String? openingHours;
  final String type;

  const ClinicEntity({
    required this.id,
    required this.name,
    required this.addressText,
    required this.city,
    this.phoneNumber,
    this.openingHours,
    required this.type,
  });
}

class DoctorClinicEntity {
  final int id;
  final int doctorId;
  final int clinicId;
  final ClinicEntity? clinicDetail;
  final DateTime startDate;

  const DoctorClinicEntity({
    required this.id,
    required this.doctorId,
    required this.clinicId,
    this.clinicDetail,
    required this.startDate,
  });
}

class AvailableSlotEntity {
  final DateTime scheduledDatetime;
  final String time;

  const AvailableSlotEntity({
    required this.scheduledDatetime,
    required this.time,
  });
}

class PatientAppointmentEntity {
  final int id;
  final int patientId;
  final int doctorId;
  final int clinicId;
  final DateTime scheduledDatetime;
  final String consultationType;
  final String status;
  final String? notes;
  final DoctorEntity? doctorDetails;
  final ClinicEntity? clinicDetails;

  const PatientAppointmentEntity({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.clinicId,
    required this.scheduledDatetime,
    required this.consultationType,
    required this.status,
    this.notes,
    this.doctorDetails,
    this.clinicDetails,
  });
}

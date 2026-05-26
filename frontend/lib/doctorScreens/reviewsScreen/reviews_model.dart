import 'reviews_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.appointmentId,
    required super.ratingWaiting,
    required super.ratingHygiene,
    required super.ratingAttentiveness,
    super.comment,
    required super.createdAt,
    required super.patientName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final appointment = json['appointment_details'] as Map<String, dynamic>?;
    final patient = appointment != null
        ? appointment['patient_details'] as Map<String, dynamic>?
        : null;

    return ReviewModel(
      id: json['id'],
      appointmentId: json['appointment'],
      ratingWaiting: json['rating_waiting'] ?? 5,
      ratingHygiene: json['rating_hygiene'] ?? 5,
      ratingAttentiveness: json['rating_attentiveness'] ?? 5,
      comment: json['comment'],
      createdAt: json['created_at'] ?? '',
      patientName: patient != null ? patient['full_name'] ?? 'Anonymous' : 'Anonymous',
    );
  }
}

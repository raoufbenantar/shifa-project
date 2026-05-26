class ReviewEntity {
  final int id;
  final int appointmentId;
  final int ratingWaiting;
  final int ratingHygiene;
  final int ratingAttentiveness;
  final String? comment;
  final String createdAt;
  final String patientName;

  const ReviewEntity({
    required this.id,
    required this.appointmentId,
    required this.ratingWaiting,
    required this.ratingHygiene,
    required this.ratingAttentiveness,
    this.comment,
    required this.createdAt,
    required this.patientName,
  });

  double get avgRating =>
      (ratingWaiting + ratingHygiene + ratingAttentiveness) / 3;
}

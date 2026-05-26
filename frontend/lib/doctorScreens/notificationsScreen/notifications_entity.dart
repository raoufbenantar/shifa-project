class NotificationEntity {
  final int id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final String createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });
}

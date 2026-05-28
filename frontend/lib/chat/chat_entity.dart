class ChatRoomEntity {
  final int id;
  final int doctor;
  final int patient;
  final String doctorName;
  final String patientName;
  final String createdAt;
  final Map<String, dynamic>? lastMessage;
  final int unreadCount;

  const ChatRoomEntity({
    required this.id,
    required this.doctor,
    required this.patient,
    required this.doctorName,
    required this.patientName,
    required this.createdAt,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory ChatRoomEntity.fromJson(Map<String, dynamic> json) {
    return ChatRoomEntity(
      id: json['id'],
      doctor: json['doctor'],
      patient: json['patient'],
      doctorName: json['doctor_name'] ?? '',
      patientName: json['patient_name'] ?? '',
      createdAt: json['created_at'] ?? '',
      lastMessage: json['last_message'],
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class ChatMessageEntity {
  final int id;
  final int room;
  final int sender;
  final String senderEmail;
  final String content;
  final String timestamp;
  final bool isRead;

  const ChatMessageEntity({
    required this.id,
    required this.room,
    required this.sender,
    required this.senderEmail,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  factory ChatMessageEntity.fromJson(Map<String, dynamic> json) {
    return ChatMessageEntity(
      id: json['id'],
      room: json['room'],
      sender: json['sender'],
      senderEmail: json['sender_email'] ?? '',
      content: json['content'],
      timestamp: json['timestamp'] ?? '',
      isRead: json['is_read'] ?? false,
    );
  }
}

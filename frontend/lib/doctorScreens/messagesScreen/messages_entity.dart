class MessageThread {
  final int appointmentId;
  final String patientName;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;

  const MessageThread({
    required this.appointmentId,
    required this.patientName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
}

class ChatMessage {
  final int id;
  final int appointmentId;
  final int senderId;
  final String senderEmail;
  final String message;
  final bool isRead;
  final String createdAt;

  const ChatMessage({
    required this.id,
    required this.appointmentId,
    required this.senderId,
    required this.senderEmail,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });
}

import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import 'messages_entity.dart';

abstract class MessagesRemoteDataSource {
  Future<List<ChatMessage>> getMessagesForAppointment(int appointmentId);
  Future<void> sendMessage(int appointmentId, String message);
  Future<void> markRead(int messageId);
  /// Returns raw appointment-message list (deduplicated to threads)
  Future<List<Map<String, dynamic>>> getAllMessages();
}

class MessagesRemoteDataSourceImpl implements MessagesRemoteDataSource {
  final _client = ApiClient.instance;

  @override
  Future<List<Map<String, dynamic>>> getAllMessages() async {
    final response = await _client.get(ApiConstants.appointmentMessages);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data is List ? data : (data['results'] ?? []);
      return List<Map<String, dynamic>>.from(list as List);
    }
    throw Exception('Failed to load messages (${response.statusCode})');
  }

  @override
  Future<List<ChatMessage>> getMessagesForAppointment(int appointmentId) async {
    final response = await _client.get(
      ApiConstants.appointmentMessages,
      queryParams: {'appointment': '$appointmentId'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data is List ? data : (data['results'] ?? []);
      return (list as List).map((j) {
        final m = j as Map<String, dynamic>;
        return ChatMessage(
          id:            m['id'],
          appointmentId: m['appointment'],
          senderId:      m['sender'],
          senderEmail:   m['sender_email'] ?? '',
          message:       m['message'],
          isRead:        m['is_read'] ?? false,
          createdAt:     m['created_at'] ?? '',
        );
      }).toList();
    }
    throw Exception('Failed to load chat (${response.statusCode})');
  }

  @override
  Future<void> sendMessage(int appointmentId, String message) async {
    final response = await _client.post(
      ApiConstants.appointmentMessages,
      body: {'appointment': appointmentId, 'message': message},
    );
    if (response.statusCode != 201) {
      final body = jsonDecode(response.body);
      throw Exception(body.toString());
    }
  }

  @override
  Future<void> markRead(int messageId) async {
    await _client.post(
        '${ApiConstants.appointmentMessages}$messageId/mark-read/');
  }
}

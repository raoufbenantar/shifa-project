import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import 'messages_entity.dart';
import 'messages_remote_datasource.dart';

// ── States ────────────────────────────────────────────────────
abstract class MessagesState {}
class MessagesInitial  extends MessagesState {}
class MessagesLoading  extends MessagesState {}
class MessagesError    extends MessagesState { final String msg; MessagesError(this.msg); }

class ThreadsLoaded extends MessagesState {
  final List<MessageThread> threads;
  ThreadsLoaded(this.threads);
}

class ChatLoaded extends MessagesState {
  final List<ChatMessage> messages;
  final int appointmentId;
  final String patientName;
  final int myUserId;
  ChatLoaded(this.messages, this.appointmentId, this.patientName, this.myUserId);
}

class ChatSending extends MessagesState {
  final List<ChatMessage> messages;
  final int appointmentId;
  final String patientName;
  final int myUserId;
  ChatSending(this.messages, this.appointmentId, this.patientName, this.myUserId);
}

// ── Cubit ─────────────────────────────────────────────────────
class MessagesCubit extends Cubit<MessagesState> {
  final MessagesRemoteDataSource _ds;
  MessagesCubit(this._ds) : super(MessagesInitial());

  Future<void> loadThreads() async {
    emit(MessagesLoading());
    try {
      final raw = await _ds.getAllMessages();
      // Group by appointment, keep the last message per thread
      final Map<int, Map<String, dynamic>> byAppt = {};
      for (final m in raw) {
        final apptId = m['appointment'] as int;
        if (!byAppt.containsKey(apptId)) {
          byAppt[apptId] = m;
        } else {
          // Keep latest
          final existing = byAppt[apptId]!['created_at'] as String? ?? '';
          final current  = m['created_at'] as String? ?? '';
          if (current.compareTo(existing) > 0) byAppt[apptId] = m;
        }
      }
      // Count unread per appointment
      final unreadMap = <int, int>{};
      for (final m in raw) {
        final apptId = m['appointment'] as int;
        final isRead = m['is_read'] as bool? ?? true;
        if (!isRead) unreadMap[apptId] = (unreadMap[apptId] ?? 0) + 1;
      }
      final threads = byAppt.entries.map((e) {
        final m = e.value;
        return MessageThread(
          appointmentId: e.key,
          patientName:   'Patient #${e.key}',
          lastMessage:   m['message'] ?? '',
          lastMessageTime: m['created_at'] ?? '',
          unreadCount:   unreadMap[e.key] ?? 0,
        );
      }).toList()
        ..sort((a, b) =>
            b.lastMessageTime.compareTo(a.lastMessageTime));
      emit(ThreadsLoaded(threads));
    } catch (e) {
      emit(MessagesError(e.toString()));
    }
  }

  Future<void> openChat(int appointmentId, String patientName) async {
    emit(MessagesLoading());
    try {
      final myId = await ApiClient.instance.getUserId() ?? 0;
      final msgs = await _ds.getMessagesForAppointment(appointmentId);
      emit(ChatLoaded(msgs, appointmentId, patientName, myId));
    } catch (e) {
      emit(MessagesError(e.toString()));
    }
  }

  Future<void> sendMessage(
      int appointmentId, String text, String patientName) async {
    final current = state;
    List<ChatMessage> existing = [];
    int myId = 0;
    if (current is ChatLoaded) {
      existing = current.messages;
      myId = current.myUserId;
      emit(ChatSending(existing, appointmentId, patientName, myId));
    }
    try {
      await _ds.sendMessage(appointmentId, text);
      final msgs = await _ds.getMessagesForAppointment(appointmentId);
      emit(ChatLoaded(msgs, appointmentId, patientName, myId));
    } catch (e) {
      emit(MessagesError(e.toString()));
    }
  }

  Future<void> refreshChat(int appointmentId, String patientName) async {
    final myId = await ApiClient.instance.getUserId() ?? 0;
    final msgs = await _ds.getMessagesForAppointment(appointmentId);
    emit(ChatLoaded(msgs, appointmentId, patientName, myId));
  }
}

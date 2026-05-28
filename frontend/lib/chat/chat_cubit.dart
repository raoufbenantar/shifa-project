import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_entity.dart';
import 'chat_remote_datasource.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class RoomsLoaded extends ChatState {
  final List<ChatRoomEntity> rooms;
  RoomsLoaded(this.rooms);
}

class ChatRoomOpened extends ChatState {
  final ChatRoomEntity room;
  final List<ChatMessageEntity> messages;
  final int myUserId;
  ChatRoomOpened(this.room, this.messages, this.myUserId);
}

class ChatMessageSending extends ChatState {
  final ChatRoomEntity room;
  final List<ChatMessageEntity> messages;
  final int myUserId;
  ChatMessageSending(this.room, this.messages, this.myUserId);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

class ChatCubit extends Cubit<ChatState> {
  final ChatRemoteDataSource _ds;
  StreamSubscription<Map<String, dynamic>>? _wsSubscription;
  int? _currentRoomId;
  int _myUserId = 0;
  String _myToken = '';

  ChatCubit(this._ds) : super(ChatInitial());

  Future<void> _loadUserId() async {
    _myUserId = await _ds.getUserId();
  }

  Future<String> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  Future<void> loadRooms() async {
    emit(ChatLoading());
    try {
      await _loadUserId();
      final rooms = await _ds.getRooms();
      emit(RoomsLoaded(rooms));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> openRoom(ChatRoomEntity room) async {
    closeRoom();
    emit(ChatLoading());
    try {
      await _loadUserId();
      _myToken = await _loadToken();
      _currentRoomId = room.id;

      final messages = await _ds.getMessages(room.id);
      _ds.markRead(room.id);
      emit(ChatRoomOpened(room, messages, _myUserId));

      _ds.connectWebSocket(room.id, _myToken);
      _wsSubscription = _ds.messageStream.listen(
        (data) {
          _onWsMessage(data, room);
        },
        onError: (error) {
          emit(ChatError('WebSocket error: $error'));
        },
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onWsMessage(Map<String, dynamic> data, ChatRoomEntity room) {
    final current = state;
    if (current is ChatRoomOpened || current is ChatMessageSending) {
      final existing = current is ChatRoomOpened
          ? current.messages
          : (current as ChatMessageSending).messages;
      final msg = ChatMessageEntity(
        id: data['message_id'] ?? 0,
        room: room.id,
        sender: data['sender_id'] ?? 0,
        senderEmail: data['sender_email'] ?? '',
        content: data['message'] ?? '',
        timestamp: data['timestamp'] ?? '',
        isRead: false,
      );
      final updated = <ChatMessageEntity>[...existing, msg];
      emit(ChatRoomOpened(room, updated, _myUserId));
    }
  }

  void sendMessage(String content) {
    final current = state;
    if (current is ChatRoomOpened) {
      emit(ChatMessageSending(current.room, current.messages, _myUserId));
      _ds.sendMessage(content);
    }
  }

  void closeRoom() {
    _wsSubscription?.cancel();
    _ds.disconnectWebSocket();
    _currentRoomId = null;
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    _ds.disconnectWebSocket();
    return super.close();
  }
}

extension on ChatRemoteDataSource {
  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 0;
  }
}

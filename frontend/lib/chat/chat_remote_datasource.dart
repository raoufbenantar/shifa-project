import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import 'chat_entity.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatRoomEntity>> getRooms();
  Future<List<ChatMessageEntity>> getMessages(int roomId);
  Future<void> markRead(int roomId);
  WebSocketChannel connectWebSocket(int roomId, String token);
  Stream<Map<String, dynamic>> get messageStream;
  void disconnectWebSocket();
  void sendMessage(String content);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final _client = ApiClient.instance;
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;

  @override
  Future<List<ChatRoomEntity>> getRooms() async {
    final response = await _client.get(ApiConstants.chatRooms);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data is List ? data : (data['results'] ?? []);
      return (list as List).map((j) =>
        ChatRoomEntity.fromJson(j as Map<String, dynamic>)
      ).toList();
    }
    throw Exception('Failed to load rooms (${response.statusCode})');
  }

  @override
  Future<List<ChatMessageEntity>> getMessages(int roomId) async {
    final response = await _client.get(
      '${ApiConstants.chatRooms}$roomId/messages/',
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((j) =>
        ChatMessageEntity.fromJson(j as Map<String, dynamic>)
      ).toList();
    }
    throw Exception('Failed to load messages (${response.statusCode})');
  }

  @override
  Future<void> markRead(int roomId) async {
    await _client.post('${ApiConstants.chatRooms}$roomId/mark_read/');
  }

  @override
  WebSocketChannel connectWebSocket(int roomId, String token) {
    final base = ApiConstants.baseUrl.replaceFirst('http', 'ws');
    final uri = Uri.parse('$base/ws/chat/$roomId/?token=$token');
    _channel = WebSocketChannel.connect(uri);
    _controller = StreamController<Map<String, dynamic>>.broadcast();

    _channel!.stream.listen(
      (data) {
        final decoded = jsonDecode(data as String) as Map<String, dynamic>;
        _controller!.add(decoded);
      },
      onError: (error) => _controller!.addError(error),
      onDone: () => _controller!.close(),
    );

    return _channel!;
  }

  @override
  Stream<Map<String, dynamic>> get messageStream {
    if (_controller == null) {
      return const Stream.empty();
    }
    return _controller!.stream;
  }

  @override
  void disconnectWebSocket() {
    _channel?.sink.close();
    _controller?.close();
    _channel = null;
    _controller = null;
  }

  @override
  void sendMessage(String content) {
    _channel?.sink.add(jsonEncode({'message': content}));
  }
}

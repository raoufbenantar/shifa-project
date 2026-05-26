import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_colors.dart';
import 'messages_cubit.dart';
import 'messages_entity.dart';
import 'messages_remote_datasource.dart';

// ═══════════════════════════════════════════════════════════════
// MessagesScreen — entry point, shows list of conversation threads
// ═══════════════════════════════════════════════════════════════
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MessagesCubit(MessagesRemoteDataSourceImpl())..loadThreads(),
      child: const _MessagesView(),
    );
  }
}

class _MessagesView extends StatelessWidget {
  const _MessagesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3ECCAF), Color(0xFF29A88E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 20),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Messages',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter')),
              SizedBox(height: 2),
              Text('Appointment conversations',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13, fontFamily: 'Inter')),
            ],
          ),
          const Spacer(),
          BlocBuilder<MessagesCubit, MessagesState>(
            builder: (ctx, _) => IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () => ctx.read<MessagesCubit>().loadThreads(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<MessagesCubit, MessagesState>(
      builder: (ctx, state) {
        if (state is MessagesLoading || state is MessagesInitial) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is MessagesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(state.msg, textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF6B7280))),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white),
                  onPressed: () => ctx.read<MessagesCubit>().loadThreads(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is ThreadsLoaded) {
          if (state.threads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 64,
                      color: AppColors.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No messages yet',
                      style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontFamily: 'Inter',
                          fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text('Messages appear after appointments are completed',
                      style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontFamily: 'Inter',
                          fontSize: 13),
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ctx.read<MessagesCubit>().loadThreads(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.threads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final t = state.threads[i];
                return _ThreadTile(
                  thread: t,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: ctx.read<MessagesCubit>()
                          ..openChat(t.appointmentId, t.patientName),
                        child: ChatScreen(
                          appointmentId: t.appointmentId,
                          patientName: t.patientName,
                        ),
                      ),
                    ),
                  ).then((_) => ctx.read<MessagesCubit>().loadThreads()),
                );
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _ThreadTile extends StatelessWidget {
  final MessageThread thread;
  final VoidCallback onTap;
  const _ThreadTile({required this.thread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasUnread = thread.unreadCount > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: hasUnread
                  ? AppColors.primary.withOpacity(0.4)
                  : const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: const Icon(Icons.person,
                      color: AppColors.primary, size: 24),
                ),
                if (hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                          color: Color(0xFFEF4444), shape: BoxShape.circle),
                      child: Center(
                        child: Text('${thread.unreadCount}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(thread.patientName,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: hasUnread
                              ? FontWeight.w700
                              : FontWeight.w600,
                          fontSize: 15,
                          color: const Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Text(thread.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: hasUnread
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: hasUnread
                              ? const Color(0xFF374151)
                              : const Color(0xFF9CA3AF))),
                ],
              ),
            ),
            Text(_formatTime(thread.lastMessageTime),
                style: TextStyle(
                    color: hasUnread ? AppColors.primary : const Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: hasUnread
                        ? FontWeight.w600
                        : FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt  = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// ChatScreen — per-appointment message thread
// ═══════════════════════════════════════════════════════════════
class ChatScreen extends StatefulWidget {
  final int appointmentId;
  final String patientName;
  const ChatScreen(
      {super.key, required this.appointmentId, required this.patientName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller    = TextEditingController();
  final _scrollCtrl    = ScrollController();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    // Poll every 5 seconds for new messages
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        context.read<MessagesCubit>().refreshChat(
            widget.appointmentId, widget.patientName);
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.3),
              child:
                  const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.patientName,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                Text('Appointment #${widget.appointmentId}',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      body: BlocConsumer<MessagesCubit, MessagesState>(
        listener: (ctx, state) {
          if (state is ChatLoaded) _scrollToBottom();
        },
        builder: (ctx, state) {
          List<ChatMessage> messages = [];
          int myId = 0;
          bool sending = false;

          if (state is ChatLoaded) {
            messages = state.messages;
            myId = state.myUserId;
          } else if (state is ChatSending) {
            messages = state.messages;
            myId = state.myUserId;
            sending = true;
          } else if (state is MessagesLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is MessagesError) {
            return Center(
                child: Text(state.msg,
                    style: const TextStyle(color: Colors.redAccent)));
          }

          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_outlined,
                                size: 56,
                                color: AppColors.primary.withOpacity(0.3)),
                            const SizedBox(height: 12),
                            const Text('No messages yet',
                                style: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontFamily: 'Inter')),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (_, i) =>
                            _ChatBubble(msg: messages[i], myId: myId),
                      ),
              ),
              _buildInputBar(ctx, sending),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputBar(BuildContext ctx, bool sending) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Write a message…',
                  hintStyle:
                      TextStyle(color: Color(0xFF9CA3AF), fontFamily: 'Inter'),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: sending
                ? null
                : () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    _controller.clear();
                    ctx.read<MessagesCubit>().sendMessage(
                        widget.appointmentId, text, widget.patientName);
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: sending ? Colors.grey : AppColors.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage msg;
  final int myId;
  const _ChatBubble({required this.msg, required this.myId});

  @override
  Widget build(BuildContext context) {
    final isMe = msg.senderId == myId;
    final time = _formatTime(msg.createdAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: const Icon(Icons.person, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 6),
          ],
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Text(
                  msg.message,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: isMe ? Colors.white : const Color(0xFF111827)),
                ),
              ),
              const SizedBox(height: 4),
              Text(time,
                  style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 10,
                      fontFamily: 'Inter')),
            ],
          ),
          if (isMe) ...[
            const SizedBox(width: 6),
            Icon(
              msg.isRead ? Icons.done_all : Icons.done,
              size: 14,
              color: msg.isRead ? AppColors.primary : const Color(0xFF9CA3AF),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}

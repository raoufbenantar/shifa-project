import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_colors.dart';
import 'notifications_cubit.dart';
import 'notifications_entity.dart';
import 'notifications_remote_datasource.dart';
import 'notifications_repository_impl.dart';
import 'notifications_usecase.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final ds = NotificationsRemoteDataSourceImpl();
        final repo = NotificationsRepositoryImpl(ds);
        return NotificationsCubit(
          GetNotificationsUseCase(repo),
          MarkNotificationAsReadUseCase(repo),
          MarkAllNotificationsAsReadUseCase(repo),
        )..load();
      },
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(ctx: context)),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alerts',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter')),
              SizedBox(height: 2),
              Text('Your notification feed',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: 'Inter')),
            ],
          ),
          const Spacer(),
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (ctx, state) {
              final showMarkAll = state is NotificationsLoaded &&
                  state.list.any((n) => !n.isRead);
              if (showMarkAll) {
                return TextButton.icon(
                  onPressed: () => ctx.read<NotificationsCubit>().markAllAsRead(),
                  icon: const Icon(Icons.done_all, color: Colors.white, size: 16),
                  label: const Text('Read All',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter')),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: () => ctx.read<NotificationsCubit>().load(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody({required BuildContext ctx}) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        if (state is NotificationsLoading || state is NotificationsInitial) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is NotificationsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 48),
                const SizedBox(height: 12),
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white),
                  onPressed: () => context.read<NotificationsCubit>().load(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is NotificationsLoaded) {
          final items = state.list;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 64,
                      color: AppColors.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No alerts to display',
                      style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontFamily: 'Inter',
                          fontSize: 15)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<NotificationsCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _NotificationTile(item: items[i]),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationEntity item;
  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;
    final time = _formatTime(item.createdAt);

    return InkWell(
      onTap: isUnread
          ? () => context.read<NotificationsCubit>().markAsRead(item.id)
          : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? Colors.white : const Color(0xFFF3F4F6).withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isUnread
                  ? AppColors.primary.withOpacity(0.3)
                  : const Color(0xFFE5E7EB)),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _typeColor(item.type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_typeIcon(item.type),
                  color: _typeColor(item.type), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight:
                                isUnread ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 14,
                            color: const Color(0xFF111827)),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 11,
                            fontFamily: 'Inter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                        color: const Color(0xFF4B5563)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'appointment_status':
        return Icons.calendar_month_outlined;
      case 'new_message':
        return Icons.chat_bubble_outline_rounded;
      case 'verification':
        return Icons.verified_user_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'appointment_status':
        return const Color(0xFF3ECCAF);
      case 'new_message':
        return const Color(0xFF6366F1);
      case 'verification':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _formatTime(String dtStr) {
    try {
      final dt = DateTime.parse(dtStr).toLocal();
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

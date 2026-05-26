import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_colors.dart';
import 'schedule_bloc.dart';
import 'schedule_cubit.dart';
import 'schedule_entity.dart';
import 'schedule_remote_datasource.dart';
import 'schedule_repository_impl.dart';
import 'schedule_usecase.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final ds   = ScheduleRemoteDataSourceImpl();
        final repo = ScheduleRepositoryImpl(ds);
        return ScheduleCubit(
          GetScheduleUseCase(repo),
          ConfirmAppointmentUseCase(repo),
          RejectAppointmentUseCase(repo),
        )..load();
      },
      child: const _ScheduleView(),
    );
  }
}

class _ScheduleView extends StatelessWidget {
  const _ScheduleView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildDatePicker(context),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(child: _buildAppointmentList(context)),
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
              Text('Schedule',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter')),
              SizedBox(height: 2),
              Text('Manage your appointments',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: 'Inter')),
            ],
          ),
          const Spacer(),
          BlocBuilder<ScheduleCubit, ScheduleState>(
            builder: (ctx, state) => IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () => ctx.read<ScheduleCubit>().load(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (ctx, state) {
        final selected = state is ScheduleLoaded
            ? state.selectedDate
            : DateTime.now();
        final today = DateTime.now();
        // Show 14 days starting 3 days before today
        final start = today.subtract(const Duration(days: 3));
        final days = List.generate(17, (i) => start.add(Duration(days: i)));

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final day = days[i];
              final isSelected = day.year == selected.year &&
                  day.month == selected.month &&
                  day.day == selected.day;
              final isToday = day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;
              return GestureDetector(
                onTap: () => ctx.read<ScheduleCubit>().selectDate(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isToday
                              ? AppColors.primary
                              : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _dayLabel(day),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? AppColors.primary
                                  : const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAppointmentList(BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (ctx, state) {
        if (state is ScheduleLoading || state is ScheduleInitial) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is ScheduleError) {
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
                  onPressed: () => ctx.read<ScheduleCubit>().load(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is ScheduleLoaded) {
          final items = state.forSelectedDate;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 56,
                      color: AppColors.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No appointments this day',
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
            onRefresh: () => ctx.read<ScheduleCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _AppointmentCard(item: items[i]),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  String _dayLabel(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }
}

class _AppointmentCard extends StatelessWidget {
  final ScheduleAppointment item;
  const _AppointmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final dt          = DateTime.tryParse(item.scheduledDatetime)?.toLocal();
    final timeLabel   = dt != null
        ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
        : '--:--';
    final statusColor = _statusColor(item.status);
    final isPending   = item.status == 'pending';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Time column
                Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(timeLabel,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.patientName,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Color(0xFF111827))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            item.consultationType == 'teleconsultation'
                                ? Icons.videocam_outlined
                                : Icons.local_hospital_outlined,
                            size: 13,
                            color: const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.consultationType == 'teleconsultation'
                                ? 'Teleconsultation'
                                : 'In-person',
                            style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                fontFamily: 'Inter'),
                          ),
                          if (item.clinicName != null) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.location_on_outlined,
                                size: 13, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(item.clinicName!,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12,
                                      fontFamily: 'Inter')),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.status[0].toUpperCase() + item.status.substring(1),
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter'),
                  ),
                ),
              ],
            ),
          ),
          // Action buttons for pending appointments
          if (isPending)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
              ),
              child: BlocBuilder<ScheduleCubit, ScheduleState>(
                builder: (ctx, state) {
                  final isActing = state is ScheduleActionInProgress &&
                      state.appointmentId == item.id;
                  return Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: isActing
                              ? null
                              : () =>
                                  ctx.read<ScheduleCubit>().reject(item.id),
                          icon: Icon(Icons.close_rounded,
                              size: 16,
                              color: isActing
                                  ? Colors.grey
                                  : const Color(0xFFEF4444)),
                          label: Text('Reject',
                              style: TextStyle(
                                  color: isActing
                                      ? Colors.grey
                                      : const Color(0xFFEF4444),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600)),
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 24,
                          color: const Color(0xFFE5E7EB)),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: isActing
                              ? null
                              : () =>
                                  ctx.read<ScheduleCubit>().confirm(item.id),
                          icon: Icon(Icons.check_rounded,
                              size: 16,
                              color: isActing ? Colors.grey : AppColors.primary),
                          label: Text('Confirm',
                              style: TextStyle(
                                  color: isActing
                                      ? Colors.grey
                                      : AppColors.primary,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600)),
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed':  return const Color(0xFF10B981);
      case 'pending':    return const Color(0xFFF59E0B);
      case 'canceled':   return const Color(0xFFEF4444);
      case 'completed':  return AppColors.primary;
      case 'rejected':   return const Color(0xFFEF4444);
      default:           return const Color(0xFF6B7280);
    }
  }
}

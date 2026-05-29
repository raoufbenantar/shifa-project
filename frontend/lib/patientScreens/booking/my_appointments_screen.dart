import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'booking_bloc.dart';
import 'booking_cubit.dart';
import 'booking_entity.dart';
import 'booking_remote_datasource.dart';
import 'booking_repository_impl.dart';
import 'booking_usecase.dart';
import 'appointment_details_screen.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final ds = BookingRemoteDataSourceImpl();
        final repo = BookingRepositoryImpl(ds);
        return BookingCubit(
          getDoctors: GetDoctorsUseCase(repo),
          getDoctorClinics: GetDoctorClinicsUseCase(repo),
          getAvailableSlots: GetAvailableSlotsUseCase(repo),
          bookAppointment: BookAppointmentUseCase(repo),
          getMyAppointments: GetMyAppointmentsUseCase(repo),
          cancelAppointment: CancelAppointmentUseCase(repo),
          rescheduleAppointment: RescheduleAppointmentUseCase(repo),
        )..loadMyAppointments();
      },
      child: const _MyAppointmentsView(),
    );
  }
}

class _MyAppointmentsView extends StatelessWidget {
  const _MyAppointmentsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
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
              Text('My Appointments',
                  style: AppTextStyles.loginTitle),
              SizedBox(height: 4),
              Text('View and manage your bookings',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: 'Inter')),
            ],
          ),
          const Spacer(),
          BlocBuilder<BookingCubit, BookingState>(
            builder: (ctx, state) => IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () => ctx.read<BookingCubit>().loadMyAppointments(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (ctx, state) {
        if (state is AppointmentListLoading || state is BookingInitial) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is BookingError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 48),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFF6B7280), fontFamily: 'Inter')),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white),
                  onPressed: () =>
                      ctx.read<BookingCubit>().loadMyAppointments(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is AppointmentListLoaded) {
          final appointments = state.appointments;
          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy_rounded,
                      size: 56,
                      color: AppColors.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No appointments yet',
                      style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontFamily: 'Inter',
                          fontSize: 15)),
                  const SizedBox(height: 8),
                  const Text('Book your first appointment with a specialist',
                      style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontFamily: 'Inter',
                          fontSize: 13)),
                ],
              ),
            );
          }

          // Sort: upcoming first, then by date descending
          final sorted = List<PatientAppointmentEntity>.from(appointments);
          sorted.sort((a, b) {
            final now = DateTime.now();
            final aFuture = a.scheduledDatetime.isAfter(now);
            final bFuture = b.scheduledDatetime.isAfter(now);
            if (aFuture && !bFuture) return -1;
            if (!aFuture && bFuture) return 1;
            return a.scheduledDatetime.compareTo(b.scheduledDatetime);
          });

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ctx.read<BookingCubit>().loadMyAppointments(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _AppointmentCard(appointment: sorted[i]),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final PatientAppointmentEntity appointment;

  const _AppointmentCard({required this.appointment});

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'canceled':
        return const Color(0xFFEF4444);
      case 'completed':
        return AppColors.primary;
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localDt = appointment.scheduledDatetime.toLocal();
    final timeLabel =
        '${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';
    final dateLabel =
        '${localDt.day}/${localDt.month}/${localDt.year}';
    final isPending = appointment.status == 'pending';
    final canCancel = appointment.status == 'pending' ||
        appointment.status == 'confirmed';
    final statusColor = _statusColor(appointment.status);
    final doctorName =
        appointment.doctorDetails?.fullName ?? 'Doctor';
    final clinicName =
        appointment.clinicDetails?.name ?? 'Clinic';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AppointmentDetailsScreen(appointment: appointment),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
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
                      color: isPending
                          ? const Color(0xFFFEF3C7)
                          : AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(timeLabel,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isPending
                                    ? const Color(0xFFF59E0B)
                                    : AppColors.primary)),
                        Text(dateLabel,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                color: isPending
                                    ? const Color(0xFFF59E0B)
                                    : AppColors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr. $doctorName',
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Color(0xFF111827))),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              appointment.consultationType == 'teleconsultation'
                                  ? Icons.videocam_outlined
                                  : Icons.local_hospital_outlined,
                              size: 13,
                              color: const Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                appointment.consultationType == 'teleconsultation'
                                    ? 'Teleconsultation'
                                    : 'In-person',
                                style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                    fontFamily: 'Inter'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.location_on_outlined,
                                size: 13, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(clinicName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12,
                                      fontFamily: 'Inter')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment.status[0].toUpperCase() +
                          appointment.status.substring(1),
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
            // Cancel button for active appointments
            if (canCancel)
              BlocBuilder<BookingCubit, BookingState>(
                builder: (ctx, state) {
                  final isActing = state is AppointmentActionInProgress &&
                      state.appointmentId == appointment.id;
                  return Container(
                    decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: Color(0xFFE5E7EB), width: 1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: isActing
                                ? null
                                : () => _confirmCancel(ctx),
                            icon: Icon(Icons.cancel_outlined,
                                size: 16,
                                color: isActing
                                    ? Colors.grey
                                    : const Color(0xFFEF4444)),
                            label: Text('Cancel',
                                style: TextStyle(
                                    color: isActing
                                        ? Colors.grey
                                        : const Color(0xFFEF4444),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600)),
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Appointment',
            style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600)),
        content: const Text(
            'Are you sure you want to cancel this appointment?',
            style: TextStyle(
                fontFamily: 'Inter', color: Color(0xFF6B7280))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Keep',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              ctx.read<BookingCubit>().cancelAppointment(appointment.id);
            },
            child: const Text('Yes, Cancel',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

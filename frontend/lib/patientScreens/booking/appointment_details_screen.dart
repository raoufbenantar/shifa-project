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
import 'book_appointment_screen.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final PatientAppointmentEntity appointment;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointment,
  });

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
        );
      },
      child: _AppointmentDetailsView(appointment: appointment),
    );
  }
}

class _AppointmentDetailsView extends StatelessWidget {
  final PatientAppointmentEntity appointment;
  const _AppointmentDetailsView({required this.appointment});

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
    final dateStr =
        '${localDt.day}/${localDt.month}/${localDt.year}';
    final timeStr =
        '${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';
    final statusColor = _statusColor(appointment.status);
    final canCancel = appointment.status == 'pending' ||
        appointment.status == 'confirmed';
    final doctorName =
        appointment.doctorDetails?.fullName ?? 'Doctor';
    final clinicName =
        appointment.clinicDetails?.name ?? 'Clinic';
    final clinicAddress =
        appointment.clinicDetails?.addressText ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3ECCAF),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Appointment Details',
            style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    appointment.status == 'confirmed'
                        ? Icons.check_circle_rounded
                        : appointment.status == 'pending'
                            ? Icons.schedule_rounded
                            : appointment.status == 'canceled'
                                ? Icons.cancel_rounded
                                : appointment.status == 'completed'
                                    ? Icons.task_alt_rounded
                                    : Icons.info_outline_rounded,
                    color: statusColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.status[0].toUpperCase() +
                            appointment.status.substring(1),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        appointment.status == 'pending'
                            ? 'Awaiting doctor confirmation'
                            : appointment.status == 'confirmed'
                                ? 'Your appointment is confirmed'
                                : appointment.status == 'completed'
                                    ? 'This appointment is completed'
                                    : 'No further action needed',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Doctor info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Doctor',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF6B7280))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(Icons.person_rounded,
                              color: AppColors.primary, size: 26),
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
                                    fontSize: 16,
                                    color: Color(0xFF111827))),
                            if (appointment.doctorDetails != null)
                              Text(
                                  appointment.doctorDetails!.specialization,
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Date & Time card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date & Time',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF6B7280))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(Icons.calendar_month_rounded,
                              color: AppColors.primary, size: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dateStr,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF111827))),
                          const SizedBox(height: 2),
                          Text(timeStr,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Color(0xFF6B7280))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Clinic card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Location',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF6B7280))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(Icons.location_on_rounded,
                              color: AppColors.primary, size: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(clinicName,
                                style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF111827))),
                            if (clinicAddress.isNotEmpty)
                              const SizedBox(height: 2),
                            if (clinicAddress.isNotEmpty)
                              Text(clinicAddress,
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Consultation type card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Consultation Type',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF6B7280))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Icon(
                            appointment.consultationType == 'teleconsultation'
                                ? Icons.videocam_rounded
                                : Icons.local_hospital_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.consultationType == 'teleconsultation'
                                ? 'Teleconsultation'
                                : 'In-person Visit',
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFF111827)),
                          ),
                          Text(
                            appointment.consultationType == 'teleconsultation'
                                ? 'Video call with doctor'
                                : 'Visit the clinic in person',
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Notes section
            if (appointment.notes != null &&
                appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notes',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF6B7280))),
                    const SizedBox(height: 8),
                    Text(appointment.notes!,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Color(0xFF111827))),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            BlocBuilder<BookingCubit, BookingState>(
              builder: (ctx, state) {
                final isActing = state is AppointmentActionInProgress &&
                    state.appointmentId == appointment.id;
                final isBusy = state is BookingInProgress;

                if (isBusy) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  );
                }

                return Column(
                  children: [
                    if (canCancel)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isActing
                              ? null
                              : () =>
                                  _confirmCancelAppointment(ctx),
                          icon: Icon(Icons.cancel_outlined,
                              size: 18,
                              color: isActing
                                  ? Colors.grey
                                  : const Color(0xFFEF4444)),
                          label: Text(
                              isActing ? 'Processing...' : 'Cancel Appointment',
                              style: TextStyle(
                                  color: isActing
                                      ? Colors.grey
                                      : const Color(0xFFEF4444),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(
                                color: Color(0xFFEF4444)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancelAppointment(BuildContext ctx) {
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
            'Are you sure you want to cancel this appointment? This action cannot be undone.',
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
              ctx
                  .read<BookingCubit>()
                  .cancelAppointment(appointment.id);
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

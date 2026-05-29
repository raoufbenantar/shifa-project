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

class DoctorDetailsScreen extends StatelessWidget {
  final DoctorEntity doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

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
        )..loadDoctorClinics(doctor.id);
      },
      child: _DoctorDetailsView(doctor: doctor),
    );
  }
}

class _DoctorDetailsView extends StatelessWidget {
  final DoctorEntity doctor;
  const _DoctorDetailsView({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3ECCAF), Color(0xFF29A88E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(4, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: doctor.image != null &&
                                    doctor.image!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.network(doctor.image!,
                                        fit: BoxFit.cover,
                                        width: 64,
                                        height: 64,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.person_rounded,
                                                color: Colors.white, size: 36)),
                                  )
                                : const Icon(Icons.person_rounded,
                                    color: Colors.white, size: 36),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dr. ${doctor.fullName}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Inter')),
                              const SizedBox(height: 4),
                              Text(doctor.specialization,
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontFamily: 'Inter')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats row
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                              label: 'Experience',
                              value:
                                  '${doctor.experienceYears} yrs'),
                          Container(
                              width: 1,
                              height: 30,
                              color: const Color(0xFFE5E7EB)),
                          _StatItem(
                              label: 'Fee',
                              value:
                                  '\$${doctor.consultationFee.toStringAsFixed(0)}'),
                          Container(
                              width: 1,
                              height: 30,
                              color: const Color(0xFFE5E7EB)),
                          _StatItem(
                            label: 'Rating',
                            value: doctor.avgRating != null
                                ? '${doctor.avgRating!.toStringAsFixed(1)}'
                                : '--',
                            isRating: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bio section
                    if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
                      const Text('About',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF111827))),
                      const SizedBox(height: 8),
                      Text(doctor.bio!,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.5)),
                      const SizedBox(height: 20),
                    ],

                    // Clinics list
                    const Text('Available Clinics',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF111827))),
                    const SizedBox(height: 10),
                    _buildClinicsSection(context),

                    const SizedBox(height: 24),

                    // Book button
                    BlocBuilder<BookingCubit, BookingState>(
                      builder: (ctx, state) {
                        final bool hasClinics;
                        if (state is DoctorClinicsLoaded) {
                          hasClinics = state.clinics.isNotEmpty;
                        } else {
                          hasClinics = false;
                        }

                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: hasClinics
                                ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            BookAppointmentScreen(
                                                doctor: doctor),
                                      ),
                                    )
                                : null,
                            child: const Text('Book Appointment',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicsSection(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (ctx, state) {
        if (state is DoctorClinicsLoading) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(20),
            child:
                CircularProgressIndicator(color: AppColors.primary),
          ));
        }
        if (state is DoctorClinicsLoaded) {
          final clinics = state.clinics;
          if (clinics.isEmpty) {
            return const Text('No clinics available',
                style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontFamily: 'Inter',
                    fontSize: 14));
          }
          return Column(
            children: clinics.map((dc) {
              final c = dc.clinicDetail;
              if (c == null) return const SizedBox();
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.local_hospital_rounded,
                            color: AppColors.primary, size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF111827))),
                          const SizedBox(height: 2),
                          Text('${c.city} - ${c.addressText}',
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Color(0xFF6B7280)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isRating;

  const _StatItem({
    required this.label,
    required this.value,
    this.isRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isRating)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded,
                  size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 2),
              Text(value,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF111827))),
            ],
          )
        else
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF111827))),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Color(0xFF6B7280))),
      ],
    );
  }
}

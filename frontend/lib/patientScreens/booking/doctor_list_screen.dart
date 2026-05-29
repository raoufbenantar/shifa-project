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
import 'doctor_details_screen.dart';

/// Patient-facing screen to browse / search approved doctors.
class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key});

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
        )..loadDoctors();
      },
      child: const _DoctorListView(),
    );
  }
}

class _DoctorListView extends StatefulWidget {
  const _DoctorListView();

  @override
  State<_DoctorListView> createState() => _DoctorListViewState();
}

class _DoctorListViewState extends State<_DoctorListView> {
  final _searchController = TextEditingController();
  String? _selectedSpecialization;

  static const _specializations = [
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Radiology',
    'General',
    'Dentistry',
    'Ophthalmology',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    setState(() {});
    context.read<BookingCubit>().loadDoctors(
          search: _searchController.text.isNotEmpty
              ? _searchController.text
              : null,
          specialization: _selectedSpecialization,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            _buildSpecializationChips(),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(child: _buildDoctorList(context)),
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Find a Doctor',
              style: AppTextStyles.loginTitle),
          SizedBox(height: 4),
          Text('Search specialists and book appointments',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _search(),
        decoration: InputDecoration(
          hintText: 'Search by name or specialization...',
          hintStyle: AppTextStyles.fieldHint,
          prefixIcon:
              const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _search();
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecializationChips() {
    return Container(
      color: Colors.white,
      height: 48,
      padding: const EdgeInsets.only(bottom: 10),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _specializations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final spec = _specializations[i];
          final selected = _selectedSpecialization == spec;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSpecialization =
                    selected ? null : spec;
              });
              _search();
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                spec,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorList(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (ctx, state) {
        if (state is DoctorListLoading) {
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
                  onPressed: () => ctx.read<BookingCubit>().loadDoctors(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is DoctorListLoaded) {
          final doctors = state.doctors;
          if (doctors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_outlined,
                      size: 56,
                      color: AppColors.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No doctors found',
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
            onRefresh: () => ctx.read<BookingCubit>().loadDoctors(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: doctors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _DoctorCard(doctor: doctors[i]),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorEntity doctor;
  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorDetailsScreen(doctor: doctor),
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
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: doctor.image != null && doctor.image!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(doctor.image!,
                            fit: BoxFit.cover, width: 52, height: 52,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.person_rounded,
                                color: AppColors.primary,
                                size: 28)),
                      )
                    : const Icon(Icons.person_rounded,
                        color: AppColors.primary, size: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${doctor.fullName}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    doctor.specialization,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (doctor.avgRating != null) ...[
                        const Icon(Icons.star_rounded,
                            size: 15, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          '${doctor.avgRating!.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        '${doctor.experienceYears} yrs exp',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${doctor.consultationFee.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

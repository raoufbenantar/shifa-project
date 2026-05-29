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

class BookAppointmentScreen extends StatefulWidget {
  final DoctorEntity doctor;

  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DoctorClinicEntity? _selectedClinic;
  DateTime _selectedDate = DateTime.now();
  AvailableSlotEntity? _selectedSlot;
  String _consultationType = 'in_person';
  final _notesController = TextEditingController();

  late final BookingCubit _cubit;

  @override
  void initState() {
    super.initState();
    final ds = BookingRemoteDataSourceImpl();
    final repo = BookingRepositoryImpl(ds);
    _cubit = BookingCubit(
      getDoctors: GetDoctorsUseCase(repo),
      getDoctorClinics: GetDoctorClinicsUseCase(repo),
      getAvailableSlots: GetAvailableSlotsUseCase(repo),
      bookAppointment: BookAppointmentUseCase(repo),
      getMyAppointments: GetMyAppointmentsUseCase(repo),
      cancelAppointment: CancelAppointmentUseCase(repo),
      rescheduleAppointment: RescheduleAppointmentUseCase(repo),
    );
    _cubit.loadDoctorClinics(widget.doctor.id);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _loadSlots() {
    if (_selectedClinic == null) return;
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    _cubit.loadAvailableSlots(
      doctorId: widget.doctor.id,
      clinicId: _selectedClinic!.clinicId,
      date: dateStr,
    );
  }

  Future<void> _book() async {
    if (_selectedClinic == null || _selectedSlot == null) return;

    await _cubit.bookAppointment(
      doctorId: widget.doctor.id,
      clinicId: _selectedClinic!.clinicId,
      scheduledDatetime: _selectedSlot!.scheduledDatetime.toIso8601String(),
      consultationType: _consultationType,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );
  }

  bool _canBook() =>
      _selectedClinic != null && _selectedSlot != null;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3ECCAF),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Book Appointment',
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
      body: BlocProvider.value(
        value: _cubit,
        child: BlocListener<BookingCubit, BookingState>(
          listenWhen: (prev, next) => next is BookingSuccess || next is BookingError,
          listener: (ctx, state) {
            if (state is BookingSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment booked successfully!'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).popUntil((r) => r.isFirst);
            } else if (state is BookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _cubit.clearError();
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor info card
                _buildDoctorInfoCard(),

                const SizedBox(height: 20),

                // Step 1: Select Clinic
                _buildSectionLabel('1. Select Clinic'),
                const SizedBox(height: 8),
                _buildClinicSelector(),

                const SizedBox(height: 20),

                // Step 2: Select Date
                _buildSectionLabel('2. Select Date'),
                const SizedBox(height: 8),
                _buildDatePicker(),

                const SizedBox(height: 20),

                // Step 3: Select Time
                _buildSectionLabel('3. Select Time'),
                const SizedBox(height: 8),
                _buildSlotGrid(),

                const SizedBox(height: 20),

                // Step 4: Consultation Type
                _buildSectionLabel('4. Consultation Type'),
                const SizedBox(height: 8),
                _buildConsultationTypeSelector(),

                const SizedBox(height: 16),

                // Notes
                _buildSectionLabel('Notes (optional)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Any special requests...',
                    hintStyle: AppTextStyles.fieldHint,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Book button
                BlocBuilder<BookingCubit, BookingState>(
                  builder: (ctx, state) {
                    final isBooking = state is BookingInProgress;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canBook()
                              ? AppColors.primary
                              : const Color(0xFFD1D5DB),
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed:
                            (_canBook() && !isBooking) ? _book : null,
                        child: isBooking
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Confirm Booking',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16)),
                      ),
                    );
                  },
                ),
                SizedBox(height: bottom + 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
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
                Text('Dr. ${widget.doctor.fullName}',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF111827))),
                const SizedBox(height: 2),
                Text(widget.doctor.specialization,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Text('\$${widget.doctor.consultationFee.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label,
        style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF111827)));
  }

  Widget _buildClinicSelector() {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (ctx, state) {
        if (state is DoctorClinicsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is DoctorClinicsLoaded) {
          final clinics = state.clinics;
          if (clinics.isEmpty) {
            return const Text('No clinics available',
                style: TextStyle(color: Color(0xFF6B7280)));
          }
          return DropdownButtonFormField<DoctorClinicEntity>(
            value: _selectedClinic,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
            hint: const Text('Choose a clinic',
                style: TextStyle(
                    fontFamily: 'Inter', color: Color(0xFF9CA3AF))),
            items: clinics.map((dc) {
              final name = dc.clinicDetail?.name ?? 'Clinic #${dc.clinicId}';
              final city = dc.clinicDetail?.city ?? '';
              return DropdownMenuItem(
                value: dc,
                child: Text('$name${city.isNotEmpty ? " - $city" : ""}',
                    style: const TextStyle(fontFamily: 'Inter')),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                _selectedClinic = v;
                _selectedSlot = null;
              });
              if (v != null) _loadSlots();
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildDatePicker() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: 14,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final day = DateTime.now().add(Duration(days: i));
          final isSelected = day.year == _selectedDate.year &&
              day.month == _selectedDate.month &&
              day.day == _selectedDate.day;
          final isToday = i == 0;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = day;
                _selectedSlot = null;
              });
              if (_selectedClinic != null) _loadSlots();
            },
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
  }

  Widget _buildSlotGrid() {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (ctx, state) {
        if (state is AvailableSlotsLoading) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(20),
            child:
                CircularProgressIndicator(color: AppColors.primary),
          ));
        }
        if (state is AvailableSlotsLoaded) {
          final slots = state.slots;
          if (slots.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Center(
                child: Text('No available slots for this date.\nPlease select another date or clinic.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontFamily: 'Inter',
                        fontSize: 13)),
              ),
            );
          }
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: slots.map((slot) {
              final isSelected = _selectedSlot == slot;
              return GestureDetector(
                onTap: () => setState(() => _selectedSlot = slot),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 42) / 4,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    slot.time,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF111827),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Center(
            child: Text('Select a clinic and date to see available slots',
                style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontFamily: 'Inter',
                    fontSize: 13)),
          ),
        );
      },
    );
  }

  Widget _buildConsultationTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _TypeOption(
            icon: Icons.person_rounded,
            label: 'In Person',
            isSelected: _consultationType == 'in_person',
            onTap: () => setState(() => _consultationType = 'in_person'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeOption(
            icon: Icons.videocam_rounded,
            label: 'Teleconsultation',
            isSelected: _consultationType == 'teleconsultation',
            onTap: () =>
                setState(() => _consultationType = 'teleconsultation'),
          ),
        ),
      ],
    );
  }

  String _dayLabel(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }
}

class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF111827),
                )),
          ],
        ),
      ),
    );
  }
}

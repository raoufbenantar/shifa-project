import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_bloc.dart';
import 'booking_usecase.dart';

class BookingCubit extends Cubit<BookingState> {
  final GetDoctorsUseCase _getDoctors;
  final GetDoctorClinicsUseCase _getDoctorClinics;
  final GetAvailableSlotsUseCase _getAvailableSlots;
  final BookAppointmentUseCase _bookAppointment;
  final GetMyAppointmentsUseCase _getMyAppointments;
  final CancelAppointmentUseCase _cancelAppointment;
  final RescheduleAppointmentUseCase _rescheduleAppointment;

  BookingCubit({
    required GetDoctorsUseCase getDoctors,
    required GetDoctorClinicsUseCase getDoctorClinics,
    required GetAvailableSlotsUseCase getAvailableSlots,
    required BookAppointmentUseCase bookAppointment,
    required GetMyAppointmentsUseCase getMyAppointments,
    required CancelAppointmentUseCase cancelAppointment,
    required RescheduleAppointmentUseCase rescheduleAppointment,
  })  : _getDoctors = getDoctors,
        _getDoctorClinics = getDoctorClinics,
        _getAvailableSlots = getAvailableSlots,
        _bookAppointment = bookAppointment,
        _getMyAppointments = getMyAppointments,
        _cancelAppointment = cancelAppointment,
        _rescheduleAppointment = rescheduleAppointment,
        super(BookingInitial());

  // ── Doctors ───────────────────────────────────────────────────

  Future<void> loadDoctors({String? search, String? specialization}) async {
    emit(DoctorListLoading());
    try {
      final list = await _getDoctors(
          search: search, specialization: specialization);
      emit(DoctorListLoaded(list));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // ── Doctor Clinics ────────────────────────────────────────────

  Future<void> loadDoctorClinics(int doctorId) async {
    emit(DoctorClinicsLoading());
    try {
      final list = await _getDoctorClinics(doctorId);
      emit(DoctorClinicsLoaded(list));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // ── Available Slots ───────────────────────────────────────────

  Future<void> loadAvailableSlots({
    required int doctorId,
    required int clinicId,
    required String date,
  }) async {
    emit(AvailableSlotsLoading());
    try {
      final list = await _getAvailableSlots(
        doctorId: doctorId,
        clinicId: clinicId,
        date: date,
      );
      emit(AvailableSlotsLoaded(list));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // ── Book Appointment ──────────────────────────────────────────

  Future<void> bookAppointment({
    required int doctorId,
    required int clinicId,
    required String scheduledDatetime,
    required String consultationType,
    String? notes,
  }) async {
    emit(BookingInProgress());
    try {
      final appointment = await _bookAppointment(
        doctorId: doctorId,
        clinicId: clinicId,
        scheduledDatetime: scheduledDatetime,
        consultationType: consultationType,
        notes: notes,
      );
      emit(BookingSuccess(appointment));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // ── My Appointments ───────────────────────────────────────────

  Future<void> loadMyAppointments() async {
    emit(AppointmentListLoading());
    try {
      final list = await _getMyAppointments();
      emit(AppointmentListLoaded(list));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // ── Cancel ────────────────────────────────────────────────────

  Future<void> cancelAppointment(int id) async {
    emit(AppointmentActionInProgress(id));
    try {
      await _cancelAppointment(id);
      // Reload the list after cancelling
      await loadMyAppointments();
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // ── Reschedule ────────────────────────────────────────────────

  Future<void> rescheduleAppointment(int id, String newDatetime) async {
    emit(AppointmentActionInProgress(id));
    try {
      await _rescheduleAppointment(id, newDatetime);
      await loadMyAppointments();
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  // ── Util ──────────────────────────────────────────────────────

  void clearError() => emit(BookingInitial());
}

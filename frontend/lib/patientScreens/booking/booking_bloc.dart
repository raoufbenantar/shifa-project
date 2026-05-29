import 'booking_entity.dart';

/// Events and states for the appointment booking flow.
///
/// This file defines a single Cubit that covers:
///  • fetching doctors                                          (DoctorListState)
///  • fetching a doctor’s clinics                                (DoctorClinicsState)
///  • fetching available slots for (doctor, clinic, date)        (SlotsState)
///  • creating a booking                                         (BookingState)
///  • listing the logged-in patient’s own appointments           (AppointmentListState)
///  • cancelling / rescheduling an appointment                   (ActionProgress -> …)
///
/// We keep one Cubit rather than six so the screen widgets can
/// share a single BlocProvider and avoid rebuilding every time.
///
// ─────────────────────────────────────────────────────────────────
//  Events
// ─────────────────────────────────────────────────────────────────

abstract class BookingEvent {}

/// Load the list of approved doctors.  Optional search / specialization.
class LoadDoctors extends BookingEvent {
  final String? search;
  final String? specialization;
  LoadDoctors({this.search, this.specialization});
}

/// Load clinics for a specific doctor (so the patient can pick one).
class LoadDoctorClinics extends BookingEvent {
  final int doctorId;
  LoadDoctorClinics(this.doctorId);
}

/// Load available time slots for a (doctor, clinic, date) combination.
class LoadAvailableSlots extends BookingEvent {
  final int doctorId;
  final int clinicId;
  final String date;
  LoadAvailableSlots(this.doctorId, this.clinicId, this.date);
}

/// Create a new appointment.
class BookAppointment extends BookingEvent {
  final int doctorId;
  final int clinicId;
  final String scheduledDatetime;
  final String consultationType;
  final String? notes;
  BookAppointment({
    required this.doctorId,
    required this.clinicId,
    required this.scheduledDatetime,
    required this.consultationType,
    this.notes,
  });
}

/// Load the patient’s own appointments.
class LoadMyAppointments extends BookingEvent {}

/// Cancel an existing appointment.
class CancelAppointment extends BookingEvent {
  final int appointmentId;
  CancelAppointment(this.appointmentId);
}

/// Reschedule an existing appointment.
class RescheduleAppointment extends BookingEvent {
  final int appointmentId;
  final String newDatetime;
  RescheduleAppointment(this.appointmentId, this.newDatetime);
}

/// Clear any error message so the UI can dismiss it.
class ClearBookingError extends BookingEvent {}

// ─────────────────────────────────────────────────────────────────
//  States
// ─────────────────────────────────────────────────────────────────

abstract class BookingState {}

class BookingInitial extends BookingState {}

// -- Doctors -------------------------------------------------------

class DoctorListLoading extends BookingState {}

class DoctorListLoaded extends BookingState {
  final List<DoctorEntity> doctors;
  DoctorListLoaded(this.doctors);
}

// -- Doctor clinics ------------------------------------------------

class DoctorClinicsLoading extends BookingState {}

class DoctorClinicsLoaded extends BookingState {
  final List<DoctorClinicEntity> clinics;
  DoctorClinicsLoaded(this.clinics);
}

// -- Available slots -----------------------------------------------

class AvailableSlotsLoading extends BookingState {}

class AvailableSlotsLoaded extends BookingState {
  final List<AvailableSlotEntity> slots;
  AvailableSlotsLoaded(this.slots);
}

// -- Booking (create) ----------------------------------------------

class BookingInProgress extends BookingState {}

class BookingSuccess extends BookingState {
  final PatientAppointmentEntity appointment;
  BookingSuccess(this.appointment);
}

// -- My appointments -----------------------------------------------

class AppointmentListLoading extends BookingState {}

class AppointmentListLoaded extends BookingState {
  final List<PatientAppointmentEntity> appointments;
  AppointmentListLoaded(this.appointments);
}

// -- Action (cancel / reschedule) -----------------------------------

class AppointmentActionInProgress extends BookingState {
  final int appointmentId;
  AppointmentActionInProgress(this.appointmentId);
}

// -- Error ---------------------------------------------------------

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}

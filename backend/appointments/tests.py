from datetime import time, timedelta

from django.test import TestCase
from django.utils import timezone

from appointments.models import Appointment
from appointments.serializers import AppointmentMessageSerializer, AppointmentSerializer, ReviewSerializer
from doctors.models import Clinic, DoctorAvailability, DoctorClinic, DoctorProfile
from doctors.serializers import DoctorAvailabilitySerializer
from patients.models import PatientProfile
from users.models import Role, User


class AppointmentBookingRulesTests(TestCase):
    def setUp(self):
        self.patient_role = Role.objects.create(name='patient')
        self.doctor_role = Role.objects.create(name='doctor')
        self.patient_user = User.objects.create(
            email='patient@example.com',
            password_hash='hash',
            role=self.patient_role,
        )
        self.doctor_user = User.objects.create(
            email='doctor@example.com',
            password_hash='hash',
            role=self.doctor_role,
        )
        self.patient = PatientProfile.objects.create(
            user=self.patient_user,
            full_name='Patient One',
            phone_number='213555000001',
        )
        self.doctor = DoctorProfile.objects.create(
            user=self.doctor_user,
            full_name='Doctor One',
            specialization='Cardiology',
            consultation_fee='2500.00',
            license_number='DOC-001',
        )
        self.clinic = Clinic.objects.create(
            name='Main Clinic',
            address_text='Street 1',
            city='Algiers',
        )
        self.appointment_date = self._next_weekday(0)
        DoctorClinic.objects.create(
            doctor=self.doctor,
            clinic=self.clinic,
            start_date=self.appointment_date - timedelta(days=1),
        )
        self.availability = DoctorAvailability.objects.create(
            doctor=self.doctor,
            clinic=self.clinic,
            day_of_week='Mon',
            start_time=time(9, 0),
            end_time=time(10, 0),
            slot_duration_minutes=30,
        )

    def _next_weekday(self, weekday):
        today = timezone.localdate()
        days_ahead = (weekday - today.weekday()) % 7
        if days_ahead == 0:
            days_ahead = 7
        return today + timedelta(days=days_ahead)

    def _scheduled_datetime(self, hour, minute):
        scheduled_datetime = timezone.datetime.combine(
            self.appointment_date,
            time(hour, minute),
        )
        return timezone.make_aware(scheduled_datetime, timezone.get_current_timezone())

    def _appointment_data(self, scheduled_datetime):
        return {
            'patient': self.patient.id,
            'doctor': self.doctor.id,
            'clinic': self.clinic.id,
            'scheduled_datetime': scheduled_datetime.isoformat(),
            'consultation_type': 'in_person',
        }

    def test_booking_requires_exact_slot_start(self):
        serializer = AppointmentSerializer(data=self._appointment_data(self._scheduled_datetime(9, 15)))

        self.assertFalse(serializer.is_valid())
        self.assertIn('scheduled_datetime', serializer.errors)

    def test_booking_accepts_available_slot(self):
        serializer = AppointmentSerializer(data=self._appointment_data(self._scheduled_datetime(9, 30)))

        self.assertTrue(serializer.is_valid(), serializer.errors)

    def test_booking_rejects_already_booked_active_slot(self):
        scheduled_datetime = self._scheduled_datetime(9, 0)
        Appointment.objects.create(
            patient=self.patient,
            doctor=self.doctor,
            clinic=self.clinic,
            scheduled_datetime=scheduled_datetime,
            status='pending',
        )

        serializer = AppointmentSerializer(data=self._appointment_data(scheduled_datetime))

        self.assertFalse(serializer.is_valid())
        self.assertIn('scheduled_datetime', serializer.errors)

    def test_booking_allows_slot_after_canceled_appointment(self):
        scheduled_datetime = self._scheduled_datetime(9, 0)
        Appointment.objects.create(
            patient=self.patient,
            doctor=self.doctor,
            clinic=self.clinic,
            scheduled_datetime=scheduled_datetime,
            status='canceled',
        )

        serializer = AppointmentSerializer(data=self._appointment_data(scheduled_datetime))

        self.assertTrue(serializer.is_valid(), serializer.errors)

    def test_availability_can_have_multiple_non_overlapping_ranges_same_day(self):
        serializer = DoctorAvailabilitySerializer(data={
            'doctor': self.doctor.id,
            'clinic': self.clinic.id,
            'day_of_week': 'Mon',
            'start_time': '14:00:00',
            'end_time': '17:00:00',
            'slot_duration_minutes': 30,
        })

        self.assertTrue(serializer.is_valid(), serializer.errors)

    def test_availability_rejects_overlapping_ranges_same_day(self):
        serializer = DoctorAvailabilitySerializer(data={
            'doctor': self.doctor.id,
            'clinic': self.clinic.id,
            'day_of_week': 'Mon',
            'start_time': '09:30:00',
            'end_time': '11:00:00',
            'slot_duration_minutes': 30,
        })

        self.assertFalse(serializer.is_valid())
        self.assertIn('non_field_errors', serializer.errors)

    def test_availability_rejects_end_time_before_start_time(self):
        serializer = DoctorAvailabilitySerializer(data={
            'doctor': self.doctor.id,
            'clinic': self.clinic.id,
            'day_of_week': 'Tue',
            'start_time': '17:00:00',
            'end_time': '09:00:00',
            'slot_duration_minutes': 30,
        })

        self.assertFalse(serializer.is_valid())
        self.assertIn('end_time', serializer.errors)

    def test_review_requires_completed_appointment(self):
        appointment = Appointment.objects.create(
            patient=self.patient,
            doctor=self.doctor,
            clinic=self.clinic,
            scheduled_datetime=self._scheduled_datetime(9, 0),
            status='confirmed',
        )
        serializer = ReviewSerializer(data={
            'appointment': appointment.id,
            'rating_waiting': 5,
            'rating_hygiene': 5,
            'rating_attentiveness': 5,
        })

        self.assertFalse(serializer.is_valid())
        self.assertIn('appointment', serializer.errors)

    def test_review_rating_must_be_between_one_and_five(self):
        appointment = Appointment.objects.create(
            patient=self.patient,
            doctor=self.doctor,
            clinic=self.clinic,
            scheduled_datetime=self._scheduled_datetime(9, 0),
            status='completed',
        )
        serializer = ReviewSerializer(data={
            'appointment': appointment.id,
            'rating_waiting': 6,
            'rating_hygiene': 5,
            'rating_attentiveness': 5,
        })

        self.assertFalse(serializer.is_valid())
        self.assertIn('rating_waiting', serializer.errors)

    def test_message_requires_completed_appointment(self):
        appointment = Appointment.objects.create(
            patient=self.patient,
            doctor=self.doctor,
            clinic=self.clinic,
            scheduled_datetime=self._scheduled_datetime(9, 0),
            consultation_type='in_person',
            status='confirmed',
        )
        serializer = AppointmentMessageSerializer(data={
            'appointment': appointment.id,
            'message': 'Hello doctor',
        })

        self.assertFalse(serializer.is_valid())
        self.assertIn('appointment', serializer.errors)

    def test_message_accepts_completed_in_person_appointment(self):
        appointment = Appointment.objects.create(
            patient=self.patient,
            doctor=self.doctor,
            clinic=self.clinic,
            scheduled_datetime=self._scheduled_datetime(9, 0),
            consultation_type='in_person',
            status='completed',
        )
        serializer = AppointmentMessageSerializer(data={
            'appointment': appointment.id,
            'message': 'Hello doctor',
        })

        self.assertTrue(serializer.is_valid(), serializer.errors)

    def test_message_rejects_empty_text(self):
        appointment = Appointment.objects.create(
            patient=self.patient,
            doctor=self.doctor,
            clinic=self.clinic,
            scheduled_datetime=self._scheduled_datetime(9, 0),
            consultation_type='in_person',
            status='completed',
        )
        serializer = AppointmentMessageSerializer(data={
            'appointment': appointment.id,
            'message': '   ',
        })

        self.assertFalse(serializer.is_valid())
        self.assertIn('message', serializer.errors)

from datetime import datetime, timedelta
from django.conf import settings
from django.db import transaction
from django.utils import timezone
from django.utils.dateparse import parse_date
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.backends import TokenBackend
from doctors.models import DoctorAvailability
from patients.models import PatientProfile
from users.models import User
from users.permissions import IsAdminOrDoctor, IsAuthenticated, get_role_from_request
from notifications.utils import send_notification
from .models import Appointment, AppointmentMessage, AppointmentStatusHistory, Review
from .serializers import (
    AppointmentMessageSerializer,
    AppointmentSerializer,
    AppointmentStatusHistorySerializer,
    ReviewSerializer,
)


def get_user_id_from_request(request):
    auth_header = request.headers.get('Authorization', '')
    if not auth_header.startswith('Bearer '):
        return None
    token = auth_header.split(' ')[1]
    try:
        backend = TokenBackend(algorithm='HS256', signing_key=settings.SECRET_KEY)
        data = backend.decode(token, verify=True)
        return data.get('user_id')
    except Exception:
        return None


class AppointmentViewSet(viewsets.ModelViewSet):
    queryset = Appointment.objects.all()
    serializer_class = AppointmentSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['status', 'consultation_type', 'doctor', 'patient', 'clinic']
    search_fields = ['patient__full_name', 'doctor__full_name']

    def get_queryset(self):
        queryset = Appointment.objects.all()
        role = get_role_from_request(self.request)
        user_id = get_user_id_from_request(self.request)

        if role == 'admin':
            return queryset
        if role == 'doctor':
            return queryset.filter(doctor__user_id=user_id)
        if role == 'patient':
            return queryset.filter(patient__user_id=user_id)
        return queryset.none()

    def get_permissions(self):
        if self.action == 'available_slots':
            return [AllowAny()]
        if self.action == 'create':
            return [IsAuthenticated()]
        if self.action in ['list', 'retrieve', 'cancel', 'reschedule']:
            return [IsAuthenticated()]
        return [IsAdminOrDoctor()]

    def create(self, request, *args, **kwargs):
        role = get_role_from_request(request)
        if role == 'doctor':
            return Response(
                {'error': 'Doctors cannot book appointments as patients.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        data = request.data.copy()
        if role == 'patient':
            try:
                patient = PatientProfile.objects.get(user_id=get_user_id_from_request(request))
            except PatientProfile.DoesNotExist:
                return Response(
                    {'error': 'Patient profile is required before booking.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            data['patient'] = patient.id

        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        appointment = serializer.save()

        # Notify doctor about new appointment
        send_notification(
            user=appointment.doctor.user,
            title='New Appointment Request',
            body=f'You have a new appointment request from {appointment.patient.full_name} on {appointment.scheduled_datetime.strftime("%Y-%m-%d %H:%M")}.',
            notif_type='appointment_status'
        )

        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def _can_doctor_manage_appointment(self, request, appointment):
        role = get_role_from_request(request)
        if role == 'admin':
            return True
        if role != 'doctor':
            return False
        return appointment.doctor.user_id == get_user_id_from_request(request)

    def _can_manage_appointment(self, request, appointment):
        role = get_role_from_request(request)
        user_id = get_user_id_from_request(request)
        if role == 'admin':
            return True
        if role == 'doctor':
            return appointment.doctor.user_id == user_id
        if role == 'patient':
            return appointment.patient.user_id == user_id
        return False

    def _is_inside_patient_change_limit(self, request, appointment):
        role = get_role_from_request(request)
        limit = timezone.now() + timezone.timedelta(hours=24)
        return role == 'patient' and appointment.status == 'confirmed' and appointment.scheduled_datetime <= limit

    def _record_status_change(self, appointment, old_status, new_status):
        AppointmentStatusHistory.objects.create(
            appointment=appointment,
            old_status=old_status,
            new_status=new_status,
        )

    def _build_slot_datetime(self, appointment_date, appointment_time):
        slot_datetime = datetime.combine(appointment_date, appointment_time)
        if settings.USE_TZ:
            slot_datetime = timezone.make_aware(slot_datetime, timezone.get_current_timezone())
        return slot_datetime

    def _serialize_available_slots(self, doctor_id, clinic_id, appointment_date):
        day_of_week = appointment_date.strftime('%a')
        active_appointment_times = set(
            Appointment.objects.filter(
                doctor_id=doctor_id,
                clinic_id=clinic_id,
                scheduled_datetime__date=appointment_date,
                status__in=AppointmentSerializer.ACTIVE_BOOKING_STATUSES,
            ).values_list('scheduled_datetime', flat=True)
        )
        slots = []
        for availability in DoctorAvailability.objects.filter(
            doctor_id=doctor_id,
            clinic_id=clinic_id,
            day_of_week=day_of_week,
        ).order_by('start_time'):
            slot_datetime = self._build_slot_datetime(appointment_date, availability.start_time)
            availability_end = self._build_slot_datetime(appointment_date, availability.end_time)
            slot_duration = timedelta(minutes=availability.slot_duration_minutes)

            while slot_datetime + slot_duration <= availability_end:
                if slot_datetime > timezone.now() and slot_datetime not in active_appointment_times:
                    slots.append({
                        'scheduled_datetime': slot_datetime.isoformat(),
                        'time': slot_datetime.strftime('%H:%M'),
                    })
                slot_datetime += slot_duration
        return slots

    def _change_pending_status(self, request, appointment, new_status):
        if not self._can_doctor_manage_appointment(request, appointment):
            return Response(
                {'error': 'You cannot manage this appointment.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        if appointment.status != 'pending':
            return Response(
                {'error': 'Only pending appointments can be confirmed or rejected.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        old_status = appointment.status
        with transaction.atomic():
            appointment.status = new_status
            appointment.save(update_fields=['status'])
            self._record_status_change(appointment, old_status, new_status)

        # Notify patient
        if new_status == 'confirmed':
            send_notification(
                user=appointment.patient.user,
                title='Appointment Confirmed',
                body=f'Your appointment with Dr. {appointment.doctor.full_name} on {appointment.scheduled_datetime.strftime("%Y-%m-%d %H:%M")} has been confirmed.',
                notif_type='appointment_status'
            )
        elif new_status == 'rejected':
            send_notification(
                user=appointment.patient.user,
                title='Appointment Rejected',
                body=f'Your appointment with Dr. {appointment.doctor.full_name} on {appointment.scheduled_datetime.strftime("%Y-%m-%d %H:%M")} has been rejected.',
                notif_type='appointment_status'
            )

        return Response(self.get_serializer(appointment).data)

    @action(detail=True, methods=['post'])
    def confirm(self, request, pk=None):
        appointment = self.get_object()
        return self._change_pending_status(request, appointment, 'confirmed')

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        appointment = self.get_object()
        return self._change_pending_status(request, appointment, 'rejected')

    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        appointment = self.get_object()
        if not self._can_manage_appointment(request, appointment):
            return Response(
                {'error': 'You cannot cancel this appointment.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        if appointment.status not in ['pending', 'confirmed']:
            return Response(
                {'error': 'Only pending or confirmed appointments can be canceled.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if self._is_inside_patient_change_limit(request, appointment):
            return Response(
                {'error': 'Confirmed appointments can only be canceled at least 24 hours before the appointment time.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        old_status = appointment.status
        with transaction.atomic():
            appointment.status = 'canceled'
            appointment.save(update_fields=['status'])
            self._record_status_change(appointment, old_status, 'canceled')

        # Notify the other party
        role = get_role_from_request(request)
        if role == 'patient':
            send_notification(
                user=appointment.doctor.user,
                title='Appointment Canceled',
                body=f'Patient {appointment.patient.full_name} has canceled their appointment on {appointment.scheduled_datetime.strftime("%Y-%m-%d %H:%M")}.',
                notif_type='appointment_status'
            )
        else:
            send_notification(
                user=appointment.patient.user,
                title='Appointment Canceled',
                body=f'Your appointment with Dr. {appointment.doctor.full_name} on {appointment.scheduled_datetime.strftime("%Y-%m-%d %H:%M")} has been canceled.',
                notif_type='appointment_status'
            )

        return Response(self.get_serializer(appointment).data)

    @action(detail=True, methods=['post'])
    def reschedule(self, request, pk=None):
        appointment = self.get_object()
        if not self._can_manage_appointment(request, appointment):
            return Response(
                {'error': 'You cannot reschedule this appointment.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        if appointment.status not in ['pending', 'confirmed']:
            return Response(
                {'error': 'Only pending or confirmed appointments can be rescheduled.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if self._is_inside_patient_change_limit(request, appointment):
            return Response(
                {'error': 'Confirmed appointments can only be rescheduled at least 24 hours before the appointment time.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if 'scheduled_datetime' not in request.data:
            return Response(
                {'scheduled_datetime': 'This field is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        data = {'scheduled_datetime': request.data.get('scheduled_datetime')}
        for optional_field in ['clinic', 'consultation_type', 'notes']:
            if optional_field in request.data:
                data[optional_field] = request.data.get(optional_field)

        serializer = self.get_serializer(appointment, data=data, partial=True)
        serializer.is_valid(raise_exception=True)

        old_status = appointment.status
        with transaction.atomic():
            serializer.save(status='pending')
            if old_status != 'pending':
                self._record_status_change(appointment, old_status, 'pending')

        # Notify doctor about reschedule
        send_notification(
            user=appointment.doctor.user,
            title='Appointment Rescheduled',
            body=f'Appointment with {appointment.patient.full_name} has been rescheduled to {appointment.scheduled_datetime.strftime("%Y-%m-%d %H:%M")}.',
            notif_type='appointment_status'
        )

        return Response(serializer.data)

    @action(detail=False, methods=['get'], url_path='available-slots')
    def available_slots(self, request):
        doctor_id = request.query_params.get('doctor')
        clinic_id = request.query_params.get('clinic')
        appointment_date = parse_date(request.query_params.get('date', ''))

        if not doctor_id or not clinic_id or not appointment_date:
            return Response(
                {'error': 'doctor, clinic, and date query parameters are required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        slots = self._serialize_available_slots(doctor_id, clinic_id, appointment_date)
        return Response({
            'doctor': doctor_id,
            'clinic': clinic_id,
            'date': appointment_date.isoformat(),
            'slots': slots,
        })


class AppointmentStatusHistoryViewSet(viewsets.ModelViewSet):
    queryset = AppointmentStatusHistory.objects.all()
    serializer_class = AppointmentStatusHistorySerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['appointment']

    def get_permissions(self):
        return [IsAdminOrDoctor()]


class AppointmentMessageViewSet(viewsets.ModelViewSet):
    queryset = AppointmentMessage.objects.select_related('appointment', 'sender')
    serializer_class = AppointmentMessageSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['appointment', 'is_read']

    def get_permissions(self):
        return [IsAuthenticated()]

    def get_queryset(self):
        queryset = AppointmentMessage.objects.select_related('appointment', 'sender')
        role = get_role_from_request(self.request)
        user_id = get_user_id_from_request(self.request)

        if role == 'admin':
            return queryset
        if role == 'doctor':
            return queryset.filter(appointment__doctor__user_id=user_id)
        if role == 'patient':
            return queryset.filter(appointment__patient__user_id=user_id)
        return queryset.none()

    def perform_create(self, serializer):
        user = User.objects.get(id=get_user_id_from_request(self.request))
        message = serializer.save(sender=user)

        # Notify the other party
        appointment = message.appointment
        if user.id == appointment.patient.user_id:
            # Patient sent message → notify doctor
            send_notification(
                user=appointment.doctor.user,
                title='New Message',
                body=f'You have a new message from {appointment.patient.full_name} regarding appointment on {appointment.scheduled_datetime.strftime("%Y-%m-%d %H:%M")}.',
                notif_type='new_message'
            )
        else:
            # Doctor sent message → notify patient
            send_notification(
                user=appointment.patient.user,
                title='New Message',
                body=f'Dr. {appointment.doctor.full_name} sent you a message regarding your appointment on {appointment.scheduled_datetime.strftime("%Y-%m-%d %H:%M")}.',
                notif_type='new_message'
            )

    @action(detail=True, methods=['post'], url_path='mark-read')
    def mark_read(self, request, pk=None):
        message = self.get_object()
        if message.sender_id != get_user_id_from_request(request):
            message.is_read = True
            message.save(update_fields=['is_read'])
        return Response(self.get_serializer(message).data)


class ReviewViewSet(viewsets.ModelViewSet):
    queryset = Review.objects.all()
    serializer_class = ReviewSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['appointment']

    def get_permissions(self):
        return [IsAuthenticated()]

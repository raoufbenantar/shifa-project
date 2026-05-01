from django.conf import settings
from django.db import transaction
from django.utils import timezone
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework_simplejwt.backends import TokenBackend
from users.permissions import IsAdminOrDoctor, IsAuthenticated, get_role_from_request
from .models import Appointment, AppointmentStatusHistory, Review
from .serializers import AppointmentSerializer, AppointmentStatusHistorySerializer, ReviewSerializer


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

    def get_permissions(self):
        if self.action == 'create':
            return [IsAuthenticated()]  # any logged in user can book
        if self.action in ['list', 'retrieve']:
            return [IsAuthenticated()]
        return [IsAdminOrDoctor()]  # only admin/doctor can update/delete

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

        data = {
            'scheduled_datetime': request.data.get('scheduled_datetime'),
        }
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

        return Response(serializer.data)


class AppointmentStatusHistoryViewSet(viewsets.ModelViewSet):
    queryset = AppointmentStatusHistory.objects.all()
    serializer_class = AppointmentStatusHistorySerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['appointment']

    def get_permissions(self):
        return [IsAdminOrDoctor()]


class ReviewViewSet(viewsets.ModelViewSet):
    queryset = Review.objects.all()
    serializer_class = ReviewSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['appointment']

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [IsAuthenticated()]
        return [IsAuthenticated()]  # any logged in user can review

from rest_framework import viewsets, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from django_filters.rest_framework import DjangoFilterBackend
from geopy.distance import geodesic

from users.permissions import IsAdminRole, IsAdminOrDoctor, IsAuthenticated
from .models import DoctorProfile, Clinic, DoctorClinic, DoctorAvailability
from .serializers import (
    DoctorSerializer, ClinicSerializer,
    DoctorClinicSerializer, DoctorAvailabilitySerializer
)
from .filters import DoctorFilter, ClinicFilter


class DoctorViewSet(viewsets.ModelViewSet):
    serializer_class = DoctorSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = DoctorFilter
    search_fields = ['full_name', 'specialization', 'bio']
    ordering_fields = ['consultation_fee', 'experience_years']
    ordering = ['full_name']

    def get_queryset(self):
        # Public listing: only approved active doctors
        if self.action in ['list', 'retrieve']:
            return DoctorProfile.objects.filter(
                is_active=True,
                verification_status='approved'
            ).distinct()
        # Admin sees all
        return DoctorProfile.objects.all().distinct()

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [AllowAny()]
        return [IsAdminRole()]

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        doctor = self.get_object()
        doctor.is_verified = True
        doctor.verification_status = 'approved'
        doctor.rejection_reason = None
        doctor.save()
        return Response({
            'message': f'Dr. {doctor.full_name} has been approved.',
            'verification_status': doctor.verification_status
        })

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        doctor = self.get_object()
        reason = request.data.get('reason', '')
        if not reason:
            return Response(
                {'error': 'A rejection reason is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        doctor.is_verified = False
        doctor.verification_status = 'rejected'
        doctor.rejection_reason = reason
        doctor.save()
        return Response({
            'message': f'Dr. {doctor.full_name} has been rejected.',
            'verification_status': doctor.verification_status,
            'rejection_reason': doctor.rejection_reason
        })

    @action(detail=False, methods=['get'])
    def pending(self, request):
        doctors = DoctorProfile.objects.filter(verification_status='pending')
        serializer = self.get_serializer(doctors, many=True)
        return Response(serializer.data)


class ClinicViewSet(viewsets.ModelViewSet):
    queryset = Clinic.objects.all()
    serializer_class = ClinicSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = ClinicFilter
    search_fields = ['name', 'city', 'address_text']
    ordering_fields = ['name', 'city']
    ordering = ['name']

    def get_permissions(self):
        if self.action in ['list', 'retrieve', 'nearby']:
            return [AllowAny()]
        return [IsAdminRole()]

    @action(detail=False, methods=['get'])
    def nearby(self, request):
        try:
            user_lat = float(request.query_params.get('lat'))
            user_lng = float(request.query_params.get('lng'))
        except (TypeError, ValueError):
            return Response(
                {'error': 'lat and lng are required and must be valid numbers.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            radius_km = float(request.query_params.get('radius_km', 10))
        except ValueError:
            radius_km = 10

        clinics = Clinic.objects.exclude(latitude=None, longitude=None)
        results = []
        user_location = (user_lat, user_lng)

        for clinic in clinics:
            clinic_location = (float(clinic.latitude), float(clinic.longitude))
            distance = geodesic(user_location, clinic_location).km
            if distance <= radius_km:
                data = ClinicSerializer(clinic).data
                data['distance_km'] = round(distance, 2)
                results.append(data)

        results.sort(key=lambda x: x['distance_km'])
        return Response(results)


class DoctorClinicViewSet(viewsets.ModelViewSet):
    queryset = DoctorClinic.objects.all()
    serializer_class = DoctorClinicSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['doctor', 'clinic']

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [IsAuthenticated()]
        return [IsAdminRole()]


class DoctorAvailabilityViewSet(viewsets.ModelViewSet):
    queryset = DoctorAvailability.objects.all()
    serializer_class = DoctorAvailabilitySerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['doctor', 'clinic', 'day_of_week']

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [AllowAny()]
        return [IsAdminOrDoctor()]

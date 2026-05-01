from rest_framework import serializers
from django.db.models import Q
from django.utils import timezone
from .models import Appointment, AppointmentStatusHistory, Review
from doctors.models import DoctorAvailability, DoctorClinic
from doctors.serializers import DoctorSerializer
from patients.serializers import PatientSerializer

class AppointmentSerializer(serializers.ModelSerializer):
    ACTIVE_BOOKING_STATUSES = ('pending', 'confirmed')

    doctor_details = DoctorSerializer(source='doctor', read_only=True)
    patient_details = PatientSerializer(source='patient', read_only=True)

    class Meta:
        model = Appointment
        fields = '__all__'

    def validate(self, attrs):
        scheduled_datetime = attrs.get('scheduled_datetime')
        doctor = attrs.get('doctor')
        clinic = attrs.get('clinic')

        if self.instance:
            scheduled_datetime = scheduled_datetime or self.instance.scheduled_datetime
            doctor = doctor or self.instance.doctor
            clinic = clinic or self.instance.clinic

        if not scheduled_datetime or not doctor or not clinic:
            return attrs

        if scheduled_datetime <= timezone.now():
            raise serializers.ValidationError({
                'scheduled_datetime': 'Appointment time must be in the future.'
            })

        appointment_date = scheduled_datetime.date()
        doctor_clinic_exists = DoctorClinic.objects.filter(
            doctor=doctor,
            clinic=clinic,
            start_date__lte=appointment_date,
        ).filter(
            Q(end_date__isnull=True) | Q(end_date__gte=appointment_date)
        ).exists()
        if not doctor_clinic_exists:
            raise serializers.ValidationError({
                'clinic': 'This doctor is not assigned to the selected clinic on this date.'
            })

        day_of_week = scheduled_datetime.strftime('%a')
        appointment_time = scheduled_datetime.time()
        is_available = DoctorAvailability.objects.filter(
            doctor=doctor,
            clinic=clinic,
            day_of_week=day_of_week,
            start_time__lte=appointment_time,
            end_time__gt=appointment_time,
        ).exists()
        if not is_available:
            raise serializers.ValidationError({
                'scheduled_datetime': 'This time is outside the doctor availability.'
            })

        conflicting_appointments = Appointment.objects.filter(
            doctor=doctor,
            scheduled_datetime=scheduled_datetime,
            status__in=self.ACTIVE_BOOKING_STATUSES,
        )
        if self.instance:
            conflicting_appointments = conflicting_appointments.exclude(pk=self.instance.pk)
        if conflicting_appointments.exists():
            raise serializers.ValidationError({
                'scheduled_datetime': 'This appointment slot is already booked.'
            })

        return attrs

    def create(self, validated_data):
        validated_data['status'] = 'pending'
        return super().create(validated_data)

class AppointmentStatusHistorySerializer(serializers.ModelSerializer):
    class Meta:
        model = AppointmentStatusHistory
        fields = '__all__'

class ReviewSerializer(serializers.ModelSerializer):
    class Meta:
        model = Review
        fields = '__all__'

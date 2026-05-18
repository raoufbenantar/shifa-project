from rest_framework import serializers
from .models import DoctorProfile, Clinic, DoctorClinic, DoctorAvailability


class ClinicSerializer(serializers.ModelSerializer):
    class Meta:
        model = Clinic
        fields = '__all__'


class DoctorAvailabilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = DoctorAvailability
        fields = '__all__'

    def validate(self, attrs):
        doctor = attrs.get('doctor')
        clinic = attrs.get('clinic')
        day_of_week = attrs.get('day_of_week')
        start_time = attrs.get('start_time')
        end_time = attrs.get('end_time')
        slot_duration_minutes = attrs.get('slot_duration_minutes')

        if self.instance:
            doctor = doctor or self.instance.doctor
            clinic = clinic or self.instance.clinic
            day_of_week = day_of_week or self.instance.day_of_week
            start_time = start_time or self.instance.start_time
            end_time = end_time or self.instance.end_time
            slot_duration_minutes = slot_duration_minutes or self.instance.slot_duration_minutes

        if start_time and end_time and end_time <= start_time:
            raise serializers.ValidationError({
                'end_time': 'End time must be after start time.'
            })

        if slot_duration_minutes is not None and slot_duration_minutes < 1:
            raise serializers.ValidationError({
                'slot_duration_minutes': 'Slot duration must be at least 1 minute.'
            })

        if doctor and clinic and day_of_week and start_time and end_time:
            overlapping = DoctorAvailability.objects.filter(
                doctor=doctor,
                clinic=clinic,
                day_of_week=day_of_week,
                start_time__lt=end_time,
                end_time__gt=start_time,
            )
            if self.instance:
                overlapping = overlapping.exclude(pk=self.instance.pk)
            if overlapping.exists():
                raise serializers.ValidationError({
                    'non_field_errors': ['Availability ranges cannot overlap.']
                })

        return attrs


class DoctorClinicSerializer(serializers.ModelSerializer):
    clinic_detail = ClinicSerializer(source='clinic', read_only=True)

    class Meta:
        model = DoctorClinic
        fields = ['id', 'doctor', 'clinic', 'clinic_detail', 'start_date', 'end_date']


class DoctorSerializer(serializers.ModelSerializer):
    clinics = DoctorClinicSerializer(many=True, read_only=True)
    availability = DoctorAvailabilitySerializer(many=True, read_only=True)
    avg_rating = serializers.SerializerMethodField()

    class Meta:
        model = DoctorProfile
        fields = [
            'id', 'user', 'full_name', 'specialization', 'experience_years',
            'consultation_fee', 'bio', 'image', 'license_number', 'is_active',
            'is_verified', 'verification_status', 'rejection_reason',
            'clinics', 'availability', 'avg_rating'
        ]

    def get_avg_rating(self, obj):
        from appointments.models import Review, Appointment
        reviews = Review.objects.filter(appointment__doctor=obj)
        if not reviews.exists():
            return None
        total = reviews.count()
        avg = (
            sum(r.rating_waiting + r.rating_hygiene + r.rating_attentiveness
                for r in reviews)
        ) / (total * 3)
        return round(avg, 2)

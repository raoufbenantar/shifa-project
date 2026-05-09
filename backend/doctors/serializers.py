from rest_framework import serializers
from .models import DoctorProfile, Clinic, DoctorClinic, DoctorAvailability

class DoctorSerializer(serializers.ModelSerializer):
    class Meta:
        model = DoctorProfile
        fields = '__all__'

class ClinicSerializer(serializers.ModelSerializer):
    class Meta:
        model = Clinic
        fields = '__all__'

class DoctorClinicSerializer(serializers.ModelSerializer):
    class Meta:
        model = DoctorClinic
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
            overlapping_availability = DoctorAvailability.objects.filter(
                doctor=doctor,
                clinic=clinic,
                day_of_week=day_of_week,
                start_time__lt=end_time,
                end_time__gt=start_time,
            )
            if self.instance:
                overlapping_availability = overlapping_availability.exclude(pk=self.instance.pk)
            if overlapping_availability.exists():
                raise serializers.ValidationError({
                    'non_field_errors': ['Availability ranges cannot overlap for the same doctor, clinic, and day.']
                })

        return attrs

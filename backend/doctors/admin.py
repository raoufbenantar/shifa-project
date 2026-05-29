from django.contrib import admin
from .models import DoctorProfile, Clinic, DoctorClinic, DoctorAvailability


@admin.register(DoctorProfile)
class DoctorProfileAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'full_name', 'specialization', 'is_verified', 'verification_status']
    list_filter = ['is_verified', 'verification_status', 'specialization']
    search_fields = ['full_name', 'user__email', 'license_number']
    readonly_fields = ['created_at', 'updated_at'] if hasattr(DoctorProfile, 'created_at') else []


@admin.register(Clinic)
class ClinicAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'city', 'type', 'phone_number']
    search_fields = ['name', 'city', 'address_text']
    list_filter = ['type', 'city']


@admin.register(DoctorClinic)
class DoctorClinicAdmin(admin.ModelAdmin):
    list_display = ['id', 'doctor', 'clinic', 'start_date', 'end_date']
    list_filter = ['start_date']


@admin.register(DoctorAvailability)
class DoctorAvailabilityAdmin(admin.ModelAdmin):
    list_display = ['id', 'doctor', 'clinic', 'day_of_week', 'start_time', 'end_time']
    list_filter = ['day_of_week']
    search_fields = ['doctor__full_name', 'clinic__name']

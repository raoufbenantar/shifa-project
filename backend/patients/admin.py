from django.contrib import admin
from .models import PatientProfile


@admin.register(PatientProfile)
class PatientProfileAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'full_name', 'phone_number', 'gender', 'date_of_birth']
    search_fields = ['full_name', 'phone_number', 'user__email']
    list_filter = ['gender']
    readonly_fields = ['user']

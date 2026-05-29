from django.contrib import admin
from .models import Appointment, AppointmentStatusHistory, AppointmentMessage, Review


@admin.register(Appointment)
class AppointmentAdmin(admin.ModelAdmin):
    list_display = ['id', 'patient', 'doctor', 'clinic', 'scheduled_datetime', 'status', 'consultation_type']
    list_filter = ['status', 'consultation_type', 'scheduled_datetime']
    search_fields = ['patient__full_name', 'doctor__full_name', 'clinic__name']
    readonly_fields = ['scheduled_datetime']


@admin.register(AppointmentStatusHistory)
class AppointmentStatusHistoryAdmin(admin.ModelAdmin):
    list_display = ['id', 'appointment', 'old_status', 'new_status', 'changed_at']
    readonly_fields = ['changed_at']


@admin.register(AppointmentMessage)
class AppointmentMessageAdmin(admin.ModelAdmin):
    list_display = ['id', 'appointment', 'sender', 'short_message', 'is_read', 'created_at']
    search_fields = ['message', 'sender__email']
    readonly_fields = ['created_at']

    def short_message(self, obj):
        return obj.message[:60] if len(obj.message) > 60 else obj.message
    short_message.short_description = 'Message'


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ['id', 'appointment', 'average_rating', 'created_at']
    list_filter = ['rating_waiting', 'rating_hygiene', 'rating_attentiveness']
    readonly_fields = ['created_at']

    def average_rating(self, obj):
        return round((obj.rating_waiting + obj.rating_hygiene + obj.rating_attentiveness) / 3, 1)
    average_rating.short_description = 'Avg Rating'

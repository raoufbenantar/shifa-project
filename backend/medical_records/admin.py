from django.contrib import admin
from .models import MedicalRecord, Consultation, Diagnosis, Medication, Prescription, Attachment


@admin.register(MedicalRecord)
class MedicalRecordAdmin(admin.ModelAdmin):
    list_display = ['id', 'patient', 'blood_type', 'created_at']
    search_fields = ['patient__full_name', 'allergies']
    list_filter = ['blood_type']
    readonly_fields = ['created_at']


@admin.register(Consultation)
class ConsultationAdmin(admin.ModelAdmin):
    list_display = ['id', 'medical_record', 'doctor', 'consultation_date', 'short_notes']
    search_fields = ['doctor__full_name', 'notes']
    list_filter = ['consultation_date']
    readonly_fields = ['consultation_date']

    def short_notes(self, obj):
        return obj.notes[:60] if obj.notes and len(obj.notes) > 60 else obj.notes
    short_notes.short_description = 'Notes'


@admin.register(Diagnosis)
class DiagnosisAdmin(admin.ModelAdmin):
    list_display = ['id', 'consultation', 'short_description']
    search_fields = ['description']

    def short_description(self, obj):
        return obj.description[:80] if len(obj.description) > 80 else obj.description
    short_description.short_description = 'Description'


@admin.register(Medication)
class MedicationAdmin(admin.ModelAdmin):
    list_display = ['id', 'name', 'short_description']
    search_fields = ['name']

    def short_description(self, obj):
        return obj.description[:80] if obj.description and len(obj.description) > 80 else obj.description or ''
    short_description.short_description = 'Description'


@admin.register(Prescription)
class PrescriptionAdmin(admin.ModelAdmin):
    list_display = ['id', 'consultation', 'medication', 'dosage', 'duration_days']
    search_fields = ['medication__name', 'dosage']


@admin.register(Attachment)
class AttachmentAdmin(admin.ModelAdmin):
    list_display = ['id', 'consultation', 'file_type', 'uploaded_at']
    list_filter = ['file_type']
    readonly_fields = ['uploaded_at']

from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from users.permissions import IsAdminRole, IsAdminOrDoctor, IsAuthenticated
from .models import MedicalRecord, Consultation, Diagnosis, Medication, Prescription, Attachment
from .serializers import (MedicalRecordSerializer, ConsultationSerializer,
    DiagnosisSerializer, MedicationSerializer, PrescriptionSerializer, AttachmentSerializer)
from .permissions import IsAdminOrDoctorOrPatientOwner


class MedicalRecordViewSet(viewsets.ModelViewSet):
    queryset = MedicalRecord.objects.all()
    serializer_class = MedicalRecordSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['patient']

    def get_permissions(self):
        return [IsAdminOrDoctorOrPatientOwner()]

    def get_queryset(self):
        user = self.request.user
        role_name = getattr(user.role, 'name', '')
        if role_name in ['admin', 'doctor']:
            return MedicalRecord.objects.all()
        patient = getattr(user, 'patient_profile', None)
        if patient:
            return MedicalRecord.objects.filter(patient=patient)
        return MedicalRecord.objects.none()


class ConsultationViewSet(viewsets.ModelViewSet):
    queryset = Consultation.objects.all()
    serializer_class = ConsultationSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['doctor', 'medical_record']

    def get_permissions(self):
        return [IsAdminOrDoctorOrPatientOwner()]

    def get_queryset(self):
        user = self.request.user
        role_name = getattr(user.role, 'name', '')
        if role_name in ['admin', 'doctor']:
            return Consultation.objects.all()
        patient = getattr(user, 'patient_profile', None)
        if patient:
            return Consultation.objects.filter(medical_record__patient=patient)
        return Consultation.objects.none()


class DiagnosisViewSet(viewsets.ModelViewSet):
    queryset = Diagnosis.objects.all()
    serializer_class = DiagnosisSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['consultation']

    def get_permissions(self):
        return [IsAdminOrDoctorOrPatientOwner()]

    def get_queryset(self):
        user = self.request.user
        role_name = getattr(user.role, 'name', '')
        if role_name in ['admin', 'doctor']:
            return Diagnosis.objects.all()
        patient = getattr(user, 'patient_profile', None)
        if patient:
            return Diagnosis.objects.filter(consultation__medical_record__patient=patient)
        return Diagnosis.objects.none()


class MedicationViewSet(viewsets.ModelViewSet):
    queryset = Medication.objects.all()
    serializer_class = MedicationSerializer
    filter_backends = [filters.SearchFilter]
    search_fields = ['name']

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [IsAuthenticated()]
        return [IsAdminOrDoctor()]


class PrescriptionViewSet(viewsets.ModelViewSet):
    queryset = Prescription.objects.all()
    serializer_class = PrescriptionSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['consultation', 'medication']

    def get_permissions(self):
        return [IsAdminOrDoctorOrPatientOwner()]

    def get_queryset(self):
        user = self.request.user
        role_name = getattr(user.role, 'name', '')
        if role_name in ['admin', 'doctor']:
            return Prescription.objects.all()
        patient = getattr(user, 'patient_profile', None)
        if patient:
            return Prescription.objects.filter(
                consultation__medical_record__patient=patient
            )
        return Prescription.objects.none()


class AttachmentViewSet(viewsets.ModelViewSet):
    queryset = Attachment.objects.all()
    serializer_class = AttachmentSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['consultation']

    def get_permissions(self):
        return [IsAdminOrDoctorOrPatientOwner()]

    def get_queryset(self):
        user = self.request.user
        role_name = getattr(user.role, 'name', '')
        if role_name in ['admin', 'doctor']:
            return Attachment.objects.all()
        patient = getattr(user, 'patient_profile', None)
        if patient:
            return Attachment.objects.filter(
                consultation__medical_record__patient=patient
            )
        return Attachment.objects.none()

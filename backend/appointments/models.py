from django.db import models
from django.core.validators import MaxValueValidator, MinValueValidator
from django.utils import timezone
from patients.models import PatientProfile
from doctors.models import DoctorProfile, Clinic
from users.models import User

class Appointment(models.Model):
    CONSULTATION_TYPES = [('in_person', 'In Person'), ('teleconsultation', 'Teleconsultation')]
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('confirmed', 'Confirmed'),
        ('completed', 'Completed'),
        ('rejected', 'Rejected'),
        ('canceled', 'Canceled'),
    ]

    patient = models.ForeignKey(PatientProfile, on_delete=models.CASCADE, related_name='appointments')
    doctor = models.ForeignKey(DoctorProfile, on_delete=models.CASCADE, related_name='appointments')
    clinic = models.ForeignKey(Clinic, on_delete=models.CASCADE, related_name='appointments')
    scheduled_datetime = models.DateTimeField()
    consultation_type = models.CharField(max_length=20, choices=CONSULTATION_TYPES, default='in_person')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    notes = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.patient.full_name} → Dr.{self.doctor.full_name} on {self.scheduled_datetime}"


class AppointmentStatusHistory(models.Model):
    appointment = models.ForeignKey(Appointment, on_delete=models.CASCADE, related_name='status_history')
    old_status = models.CharField(max_length=20)
    new_status = models.CharField(max_length=20)
    changed_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"Appointment #{self.appointment.id}: {self.old_status} → {self.new_status}"


class AppointmentMessage(models.Model):
    appointment = models.ForeignKey(Appointment, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='appointment_messages')
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(default=timezone.now)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f"Message for Appointment #{self.appointment.id} by {self.sender.email}"


class Review(models.Model):
    appointment = models.OneToOneField(Appointment, on_delete=models.CASCADE, related_name='review')
    rating_waiting = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    rating_hygiene = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    rating_attentiveness = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    comment = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"Review for Appointment #{self.appointment.id}"

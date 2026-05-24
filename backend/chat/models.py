from django.db import models
from users.models import User
from doctors.models import DoctorProfile
from patients.models import PatientProfile


class ChatRoom(models.Model):
    doctor = models.ForeignKey(DoctorProfile, on_delete=models.CASCADE, related_name='chat_rooms')
    patient = models.ForeignKey(PatientProfile, on_delete=models.CASCADE, related_name='chat_rooms')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('doctor', 'patient')

    def __str__(self):
        return f"Chat: {self.patient.full_name} ↔ Dr. {self.doctor.full_name}"


class ChatMessage(models.Model):
    room = models.ForeignKey(ChatRoom, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='chat_messages')
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)

    class Meta:
        ordering = ['timestamp']

    def __str__(self):
        return f"{self.sender.email}: {self.content[:50]}"

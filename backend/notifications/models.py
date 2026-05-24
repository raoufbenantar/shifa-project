from django.db import models
from users.models import User


class Notification(models.Model):
    NOTIFICATION_TYPES = [
        ('appointment_status', 'Appointment Status'),
        ('new_message', 'New Message'),
        ('reminder', 'Reminder'),
        ('verification', 'Verification'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=255)
    body = models.TextField()
    type = models.CharField(max_length=30, choices=NOTIFICATION_TYPES)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.email} - {self.title}"

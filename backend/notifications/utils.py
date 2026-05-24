from .models import Notification


def send_notification(user, title, body, notif_type='appointment_status'):
    """
    Create a notification for a user.
    Call this from anywhere in the project.
    
    Usage:
        from notifications.utils import send_notification
        send_notification(user, "Appointment Confirmed", "Your appointment is confirmed.", 'appointment_status')
    """
    Notification.objects.create(
        user=user,
        title=title,
        body=body,
        type=notif_type
    )

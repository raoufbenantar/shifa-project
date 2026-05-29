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


def send_fcm_notification(user_id, title, body, data=None):
    """Send FCM push notification to all active devices of a user."""
    try:
        import firebase_admin
        from firebase_admin import messaging
        from django.conf import settings

        from .models import DeviceToken

        tokens = list(DeviceToken.objects.filter(
            user_id=user_id, is_active=True
        ).values_list('token', flat=True))

        if not tokens:
            return

        # Lazily initialize Firebase app
        try:
            firebase_admin.get_app()
        except ValueError:
            cred_path = getattr(settings, 'FIREBASE_CREDENTIALS_PATH', None)
            if cred_path:
                cred = firebase_admin.credentials.Certificate(cred_path)
                firebase_admin.initialize_app(cred)
            else:
                return  # Firebase not configured

        message = messaging.MulticastMessage(
            tokens=tokens,
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data={k: str(v) for k, v in (data or {}).items()},
        )

        response = messaging.send_each_for_multicast(message)
        if response.failure_count > 0:
            invalid_tokens = []
            for idx, resp in enumerate(response.responses):
                if not resp.success:
                    invalid_tokens.append(tokens[idx])
            if invalid_tokens:
                DeviceToken.objects.filter(token__in=invalid_tokens).update(is_active=False)
    except Exception:
        pass  # FCM is best-effort; never crash the app

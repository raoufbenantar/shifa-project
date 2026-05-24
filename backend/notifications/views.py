from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from users.permissions import IsAuthenticated
from users.permissions import get_role_from_request
from rest_framework_simplejwt.backends import TokenBackend
from django.conf import settings
from .models import Notification
from .serializers import NotificationSerializer


def get_user_id_from_request(request):
    auth_header = request.headers.get('Authorization', '')
    if not auth_header.startswith('Bearer '):
        return None
    token = auth_header.split(' ')[1]
    try:
        backend = TokenBackend(algorithm='HS256', signing_key=settings.SECRET_KEY)
        data = backend.decode(token, verify=True)
        return data.get('user_id')
    except Exception:
        return None


class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = NotificationSerializer

    def get_permissions(self):
        return [IsAuthenticated()]

    def get_queryset(self):
        user_id = get_user_id_from_request(self.request)
        return Notification.objects.filter(user_id=user_id)

    @action(detail=True, methods=['post'])
    def read(self, request, pk=None):
        notification = self.get_object()
        notification.is_read = True
        notification.save()
        return Response({'message': 'Notification marked as read.'})

    @action(detail=False, methods=['post'])
    def read_all(self, request):
        user_id = get_user_id_from_request(request)
        Notification.objects.filter(user_id=user_id, is_read=False).update(is_read=True)
        return Response({'message': 'All notifications marked as read.'})

    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        user_id = get_user_id_from_request(request)
        count = Notification.objects.filter(user_id=user_id, is_read=False).count()
        return Response({'unread_count': count})

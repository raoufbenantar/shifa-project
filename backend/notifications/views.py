from rest_framework import viewsets, status
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from users.permissions import IsAuthenticated
from users.permissions import get_role_from_request
from rest_framework_simplejwt.backends import TokenBackend
from django.conf import settings
from .models import Notification, DeviceToken
from .serializers import NotificationSerializer, DeviceTokenSerializer


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


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def register_device_token(request):
    serializer = DeviceTokenSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    token_obj, created = DeviceToken.objects.update_or_create(
        token=serializer.validated_data['token'],
        defaults={
            'user': request.user,
            'platform': serializer.validated_data['platform'],
            'is_active': True,
        }
    )
    return Response({
        'message': 'Token registered successfully',
        'token_id': token_obj.id,
    }, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def unregister_device_token(request):
    serializer = DeviceTokenSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    DeviceToken.objects.filter(
        token=serializer.validated_data['token'],
        user=request.user,
    ).update(is_active=False)

    return Response({'message': 'Token unregistered successfully'})

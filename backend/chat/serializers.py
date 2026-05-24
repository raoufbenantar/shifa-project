from rest_framework import serializers
from .models import ChatRoom, ChatMessage


class ChatMessageSerializer(serializers.ModelSerializer):
    sender_email = serializers.CharField(source='sender.email', read_only=True)

    class Meta:
        model = ChatMessage
        fields = ['id', 'room', 'sender', 'sender_email', 'content', 'timestamp', 'is_read']
        read_only_fields = ['id', 'sender', 'timestamp']


class ChatRoomSerializer(serializers.ModelSerializer):
    doctor_name = serializers.CharField(source='doctor.full_name', read_only=True)
    patient_name = serializers.CharField(source='patient.full_name', read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = ChatRoom
        fields = ['id', 'doctor', 'patient', 'doctor_name', 'patient_name',
                  'created_at', 'last_message', 'unread_count']

    def get_last_message(self, obj):
        msg = obj.messages.last()
        if msg:
            return {'content': msg.content, 'timestamp': msg.timestamp}
        return None

    def get_unread_count(self, obj):
        request = self.context.get('request')
        if not request:
            return 0
        # Get user_id from token instead of request.user
        from django.conf import settings
        from rest_framework_simplejwt.backends import TokenBackend
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            return 0
        token = auth_header.split(' ')[1]
        try:
            backend = TokenBackend(algorithm='HS256', signing_key=settings.SECRET_KEY)
            data = backend.decode(token, verify=True)
            user_id = data.get('user_id')
            return obj.messages.filter(is_read=False).exclude(sender_id=user_id).count()
        except Exception:
            return 0

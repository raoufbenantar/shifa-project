from django.contrib import admin
from .models import ChatRoom, ChatMessage


@admin.register(ChatRoom)
class ChatRoomAdmin(admin.ModelAdmin):
    list_display = ['id', 'doctor', 'patient', 'created_at']
    search_fields = ['doctor__full_name', 'patient__full_name']
    readonly_fields = ['created_at']


@admin.register(ChatMessage)
class ChatMessageAdmin(admin.ModelAdmin):
    list_display = ['id', 'room', 'sender', 'short_content', 'is_read', 'timestamp']
    search_fields = ['sender__email', 'content']
    list_filter = ['is_read']
    readonly_fields = ['timestamp']

    def short_content(self, obj):
        return obj.content[:60] if len(obj.content) > 60 else obj.content
    short_content.short_description = 'Content'

from rest_framework import serializers
from .models import PatientProfile

class PatientSerializer(serializers.ModelSerializer):
    user_email = serializers.EmailField(source='user.email', read_only=True)

    class Meta:
        model = PatientProfile
        fields = '__all__'

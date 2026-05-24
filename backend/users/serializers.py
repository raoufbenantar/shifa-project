from rest_framework import serializers
from django.contrib.auth.hashers import make_password
from django.db import transaction
from doctors.models import DoctorProfile
from patients.models import PatientProfile
from .models import User, Role

class RoleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Role
        fields = '__all__'

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['id', 'email', 'password', 'role']

    def create(self, validated_data):
        validated_data['password_hash'] = make_password(validated_data.pop('password'))
        return super().create(validated_data)


class PatientRegisterSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, min_length=8)
    full_name = serializers.CharField(max_length=100)
    phone_number = serializers.CharField(max_length=16)
    date_of_birth = serializers.DateField(required=False, allow_null=True)
    national_id = serializers.CharField(max_length=50, required=False, allow_blank=True)

    def validate_email(self, email):
        if User.objects.filter(email=email).exists():
            raise serializers.ValidationError('A user with this email already exists.')
        return email

    def validate_phone_number(self, phone_number):
        if PatientProfile.objects.filter(phone_number=phone_number).exists():
            raise serializers.ValidationError('A patient with this phone number already exists.')
        return phone_number

    @transaction.atomic
    def create(self, validated_data):
        role, _ = Role.objects.get_or_create(name='patient')
        user = User.objects.create(
            email=validated_data['email'],
            password_hash=make_password(validated_data['password']),
            role=role,
        )
        PatientProfile.objects.create(
            user=user,
            full_name=validated_data['full_name'],
            phone_number=validated_data['phone_number'],
            date_of_birth=validated_data.get('date_of_birth'),
            national_id=validated_data.get('national_id') or None,
        )
        return user


class DoctorRegisterSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, min_length=8)
    full_name = serializers.CharField(max_length=100)
    phone_number = serializers.CharField(max_length=16, required=False, allow_blank=True)
    specialization = serializers.CharField(max_length=100)
    license_number = serializers.CharField(max_length=50)

    def validate_email(self, email):
        if User.objects.filter(email=email).exists():
            raise serializers.ValidationError('A user with this email already exists.')
        return email

    def validate_license_number(self, license_number):
        if DoctorProfile.objects.filter(license_number=license_number).exists():
            raise serializers.ValidationError('A doctor with this license number already exists.')
        return license_number

    @transaction.atomic
    def create(self, validated_data):
        role, _ = Role.objects.get_or_create(name='doctor')
        user = User.objects.create(
            email=validated_data['email'],
            password_hash=make_password(validated_data['password']),
            role=role,
        )
        DoctorProfile.objects.create(
            user=user,
            full_name=validated_data['full_name'],
            phone_number=validated_data.get('phone_number', ''),
            specialization=validated_data['specialization'],
            license_number=validated_data['license_number'],
        )
        return user

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'role', 'is_active']

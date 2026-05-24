from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, viewsets
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError, InvalidToken
from rest_framework_simplejwt.backends import TokenBackend
from django.conf import settings
from django.contrib.auth.hashers import check_password
from .models import User, Role
from .serializers import (
    DoctorRegisterSerializer,
    PatientRegisterSerializer,
    RegisterSerializer,
    RoleSerializer,
    UserSerializer,
)


def get_tokens_for_user(user):
    refresh = RefreshToken()
    refresh['user_id'] = user.id
    refresh['email'] = user.email
    refresh['role'] = user.role.name if user.role else None
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


def get_user_payload(user):
    role_name = user.role.name if user.role else None
    frontend_role_id = {'patient': 1, 'doctor': 2, 'admin': 3}.get(role_name, user.role_id)
    profile = {}
    if role_name == 'patient' and hasattr(user, 'patient_profile'):
        patient = user.patient_profile
        profile = {
            'id': patient.id,
            'full_name': patient.full_name,
            'phone_number': patient.phone_number,
            'date_of_birth': patient.date_of_birth.isoformat() if patient.date_of_birth else None,
            'national_id': patient.national_id,
        }
    if role_name == 'doctor' and hasattr(user, 'doctor_profile'):
        doctor = user.doctor_profile
        profile = {
            'id': doctor.id,
            'full_name': doctor.full_name,
            'phone_number': doctor.phone_number,
            'specialization': doctor.specialization,
            'experience_years': doctor.experience_years,
            'consultation_fee': float(doctor.consultation_fee),
            'bio': doctor.bio or '',
            'license_number': doctor.license_number,
            'image': doctor.image.url if doctor.image else None,
        }
    return {
        'id': user.id,
        'email': user.email,
        'role_id': frontend_role_id,
        'role': role_name,
        'is_active': user.is_active,
        'profile': profile,
    }


def get_auth_response(user):
    tokens = get_tokens_for_user(user)
    return {
        'token': tokens['access'],
        'access': tokens['access'],
        'refresh': tokens['refresh'],
        'user': get_user_payload(user),
    }


def decode_token(request):
    auth_header = request.headers.get('Authorization', '')
    if not auth_header.startswith('Bearer '):
        return None
    token = auth_header.split(' ')[1]
    try:
        backend = TokenBackend(algorithm='HS256', signing_key=settings.SECRET_KEY)
        data = backend.decode(token, verify=True)
        return data
    except Exception:
        return None


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response(get_auth_response(user), status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class PatientRegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = PatientRegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response(get_auth_response(user), status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class DoctorRegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = DoctorRegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response(get_auth_response(user), status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
        if not check_password(password, user.password_hash):
            return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
        if not user.is_active:
            return Response({'error': 'Account is disabled'}, status=status.HTTP_403_FORBIDDEN)
        return Response(get_auth_response(user))


class LogoutView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        try:
            token = RefreshToken(request.data.get('refresh'))
            token.blacklist()
            return Response({'message': 'Logged out successfully'})
        except Exception:
            return Response({'error': 'Invalid token'}, status=status.HTTP_400_BAD_REQUEST)


class MeView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        payload = decode_token(request)
        if not payload:
            return Response({'error': 'Invalid or missing token'}, status=status.HTTP_401_UNAUTHORIZED)
        try:
            user = User.objects.get(id=payload['user_id'])
            return Response(get_user_payload(user))
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)


class RoleViewSet(viewsets.ModelViewSet):
    permission_classes = [AllowAny]
    queryset = Role.objects.all()
    serializer_class = RoleSerializer

from django.test import TestCase
from rest_framework.test import APIClient

from doctors.models import DoctorProfile
from patients.models import PatientProfile
from users.models import Role, User


class AuthEndpointTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        Role.objects.create(name='patient')
        Role.objects.create(name='doctor')

    def test_patient_register_creates_user_profile_and_tokens(self):
        response = self.client.post('/api/auth/register/patient/', {
            'email': 'patient@example.com',
            'password': 'password123',
            'full_name': 'Patient One',
            'phone_number': '+213555000001',
            'date_of_birth': '1998-01-01',
            'national_id': 'NAT-001',
        }, format='json')

        self.assertEqual(response.status_code, 201)
        self.assertIn('token', response.data)
        self.assertIn('refresh', response.data)
        self.assertEqual(response.data['user']['role'], 'patient')
        self.assertEqual(response.data['user']['role_id'], 1)
        self.assertEqual(response.data['user']['profile']['full_name'], 'Patient One')
        self.assertTrue(PatientProfile.objects.filter(phone_number='+213555000001').exists())

    def test_doctor_register_creates_user_profile_and_tokens(self):
        response = self.client.post('/api/auth/register/doctor/', {
            'email': 'doctor@example.com',
            'password': 'password123',
            'full_name': 'Doctor One',
            'phone_number': '+213555000002',
            'specialization': 'Cardiology',
            'license_number': 'DOC-001',
        }, format='json')

        self.assertEqual(response.status_code, 201)
        self.assertIn('token', response.data)
        self.assertEqual(response.data['user']['role'], 'doctor')
        self.assertEqual(response.data['user']['role_id'], 2)
        self.assertEqual(response.data['user']['profile']['specialization'], 'Cardiology')
        self.assertTrue(DoctorProfile.objects.filter(license_number='DOC-001').exists())

    def test_login_returns_frontend_auth_payload(self):
        register_response = self.client.post('/api/auth/register/patient/', {
            'email': 'login@example.com',
            'password': 'password123',
            'full_name': 'Login Patient',
            'phone_number': '+213555000003',
        }, format='json')
        self.assertEqual(register_response.status_code, 201)

        response = self.client.post('/api/auth/login/', {
            'email': 'login@example.com',
            'password': 'password123',
        }, format='json')

        self.assertEqual(response.status_code, 200)
        self.assertIn('token', response.data)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)
        self.assertEqual(response.data['user']['profile']['full_name'], 'Login Patient')

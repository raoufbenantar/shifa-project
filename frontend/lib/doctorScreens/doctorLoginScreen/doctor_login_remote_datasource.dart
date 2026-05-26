import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'doctor_model.dart';

abstract class DoctorLoginRemoteDataSource {
  Future<DoctorModel> loginDoctor({
    required String email,
    required String password,
  });
}

// ── Mock (kept for offline testing) ──────────────────────────
class DoctorLoginRemoteDataSourceMock implements DoctorLoginRemoteDataSource {
  @override
  Future<DoctorModel> loginDoctor({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return DoctorModel.fromJson({
      'token': 'mock.jwt.token.doctor',
      'user': {
        'id': 2,
        'email': email,
        'role_id': 2,
        'is_active': true,
        'profile': {
          'full_name': 'Dr. Ahmed Belkacem',
          'specialization': 'Cardiologist',
          'experience_years': 12,
          'consultation_fee': 2500.0,
          'bio': 'Senior cardiologist at Algiers Central Clinic.',
        },
      },
    });
  }
}

// ── Real Implementation ───────────────────────────────────────
class DoctorLoginRemoteDataSourceImpl implements DoctorLoginRemoteDataSource {
  // 10.0.2.2 = Android emulator → localhost
  // For web/desktop use 127.0.0.1
  static const String _baseUrl = 'http://127.0.0.1:8000';

  @override
  Future<DoctorModel> loginDoctor({
    required String email,
    required String password,
  }) async {
    // Step 1 — Login to get tokens
    final loginResponse = await http.post(
      Uri.parse('$_baseUrl/api/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (loginResponse.statusCode != 200) {
      final error = jsonDecode(loginResponse.body);
      throw Exception(error['error'] ?? 'Login failed');
    }

    final loginData = jsonDecode(loginResponse.body) as Map<String, dynamic>;
    final accessToken = loginData['access'] as String;
    final userData = loginData['user'] as Map<String, dynamic>;
    final userId = userData['id'] as int;
    final roleId = userData['role'] as int;

    // Step 2 — Save token to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', loginData['refresh'] as String);
    await prefs.setInt('user_id', userId);
    await prefs.setInt('role_id', roleId);

    // Step 3 — Fetch doctor profile
    final profileResponse = await http.get(
      Uri.parse('$_baseUrl/api/doctors/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    String fullName = '';
    String specialization = '';
    int experienceYears = 0;
    double consultationFee = 0.0;
    String bio = '';
    int doctorId = 0;

    if (profileResponse.statusCode == 200) {
      final doctors = jsonDecode(profileResponse.body) as List;
      // Find the doctor profile matching this user
      final doctorProfile = doctors.firstWhere(
        (d) => d['user'] == userId,
        orElse: () => null,
      );
      if (doctorProfile != null) {
        doctorId = doctorProfile['id'];
        fullName = doctorProfile['full_name'] ?? '';
        specialization = doctorProfile['specialization'] ?? '';
        experienceYears = doctorProfile['experience_years'] ?? 0;
        consultationFee = double.tryParse(doctorProfile['consultation_fee'].toString()) ?? 0.0;
        bio = doctorProfile['bio'] ?? '';
        await prefs.setInt('doctor_id', doctorId);
      }
    }

    // Step 4 — Return DoctorModel in expected format
    return DoctorModel.fromJson({
      'token': accessToken,
      'user': {
        'id': userId,
        'email': email,
        'role_id': roleId,
        'is_active': userData['is_active'] ?? true,
        'profile': {
          'full_name': fullName,
          'specialization': specialization,
          'experience_years': experienceYears,
          'consultation_fee': consultationFee,
          'bio': bio,
        },
      },
    });
  }
}

class DoctorLoginRemoteDataSourceImpl implements DoctorLoginRemoteDataSource {
  final http.Client _client;

  DoctorLoginRemoteDataSourceImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<DoctorModel> loginDoctor({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Login failed');
    }

    final doctor = DoctorModel.fromJson(data);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access', data['access'] as String? ?? doctor.token);
    await prefs.setString('refresh', data['refresh'] as String? ?? '');
    await prefs.setString('role', data['user']['role'] as String? ?? 'doctor');
    return doctor;
  }
}

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
          'bio': 'Senior cardiologist.',
        },
      },
    });
  }
}

// ── Real Implementation ───────────────────────────────────────
class DoctorLoginRemoteDataSourceImpl implements DoctorLoginRemoteDataSource {
  static const String _baseUrl = 'http://127.0.0.1:8000';

  @override
  Future<DoctorModel> loginDoctor({
    required String email,
    required String password,
  }) async {
    final loginResponse = await http.post(
      Uri.parse('$_baseUrl/api/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (loginResponse.statusCode != 200) {
      final error = jsonDecode(loginResponse.body);
      throw Exception(error['error'] ?? 'Login failed');
    }

    final data = jsonDecode(loginResponse.body) as Map<String, dynamic>;
    final userData = data['user'] as Map<String, dynamic>;
    final profile = userData['profile'] as Map<String, dynamic>? ?? {};

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', data['access'] as String);
    await prefs.setString('refresh_token', data['refresh'] as String);
    await prefs.setInt('user_id', userData['id'] as int);
    await prefs.setInt('role_id', userData['role_id'] as int);
    if (profile['id'] != null) {
      await prefs.setInt('doctor_id', profile['id'] as int);
    }

    // Return DoctorModel directly from login response
    return DoctorModel.fromJson({
      'token': data['token'],
      'user': {
        'id': userData['id'],
        'email': userData['email'],
        'role_id': userData['role_id'],
        'is_active': userData['is_active'],
        'profile': {
          'full_name': profile['full_name'] ?? '',
          'specialization': profile['specialization'] ?? '',
          'experience_years': profile['experience_years'] ?? 0,
          'consultation_fee': profile['consultation_fee'] ?? 0.0,
          'bio': profile['bio'] ?? '',
        },
      },
    });
  }
}

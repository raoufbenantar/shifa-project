import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shifa/core/api_config.dart';
import 'package:shifa/patientScreens/user_model.dart';



// ─────────────────────────────────────────────────────────────
// DATA LAYER → Login Remote Data Source
//
// WHY abstract + mock pattern (same as SignupDataSource)?
// The mock lets the app run and be demonstrated without a
// live backend.  When the real API is ready, create
// LoginRemoteDataSourceImpl that does the actual http.post(),
// register it in the DI wiring inside PatientLoginScreen,
// and nothing else changes.
// ─────────────────────────────────────────────────────────────

abstract class LoginRemoteDataSource {
  Future<UserModel> loginPatient({
    required String email,
    required String password,
  });
}

// ── Mock implementation ───────────────────────────────────────
class LoginRemoteDataSourceMock implements LoginRemoteDataSource {
  @override
  Future<UserModel> loginPatient({
    required String email,
    required String password,
  }) async {
    // Simulate 1-second network round-trip.
    await Future.delayed(const Duration(seconds: 1));

    // ── Simulate a wrong-credentials error ───────────────
    // Uncomment to test the LoginFailure state:
    // throw Exception('Invalid email or password.');

    // ── Happy-path mock response ──────────────────────────
    // Mirrors the JSON structure the real backend will return.
    // role_id = 1 → maps to roles.name = 'patient'
    return UserModel.fromJson({
      'token': 'mock.jwt.token.patient',
      'user': {
        'id': 1,
        'email': email,
        'role_id': 1,        // patient role — must match kPatientRoleId
        'is_active': true,
        'profile': {
          'full_name': 'Ali Ben Salah',
          'phone_number': '+213551234567',
        },
      },
    });

    // ── Real implementation (swap when backend is ready) ──
    // final response = await http.post(
    //   Uri.parse('https://your-api.com/auth/login'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'email': email, 'password': password}),
    // );
    // if (response.statusCode == 200) {
    //   return UserModel.fromJson(jsonDecode(response.body));
    // } else {
    //   final msg = jsonDecode(response.body)['message'] ?? 'Login failed';
    //   throw Exception(msg);
    // }
  }
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final http.Client _client;

  LoginRemoteDataSourceImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<UserModel> loginPatient({
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

    final user = UserModel.fromJson(data);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access', data['access'] as String? ?? user.token);
    await prefs.setString('refresh', data['refresh'] as String? ?? '');
    await prefs.setString('role', data['user']['role'] as String? ?? 'patient');
    return user;
  }
}

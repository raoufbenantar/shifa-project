
// ─────────────────────────────────────────────────────────────
// DATA LAYER → Doctor Signup Remote Data Source
//
// Same mock-first pattern used across all auth features.
// When the backend is ready:
//   1. Create DoctorSignupRemoteDataSourceImpl
//   2. Inject it instead of the mock inside DoctorSignupScreen
//   3. Zero changes to Domain or Presentation layers.
// ─────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shifa/core/api_config.dart';

import 'doctor_signup_model.dart';

abstract class DoctorSignupRemoteDataSource {
  Future<void> registerDoctor(DoctorSignupModel model);
}

class DoctorSignupRemoteDataSourceMock
    implements DoctorSignupRemoteDataSource {
  @override
  Future<void> registerDoctor(DoctorSignupModel model) async {
    // Simulate 1-second network round-trip.
    await Future.delayed(const Duration(seconds: 1));

    // ── Simulate server error (uncomment to test Failure state)
    // throw Exception('License number already registered.');

    // ── Real implementation template ─────────────────────
    // final response = await http.post(
    //   Uri.parse('https://your-api.com/auth/register/doctor'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(model.toJson()),
    // );
    // if (response.statusCode != 201) {
    //   final msg = jsonDecode(response.body)['message'] ?? 'Registration failed';
    //   throw Exception(msg);
    // }
  }
}

class DoctorSignupRemoteDataSourceImpl implements DoctorSignupRemoteDataSource {
  final http.Client _client;

  DoctorSignupRemoteDataSourceImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<void> registerDoctor(DoctorSignupModel model) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register/doctor/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(model.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception(_errorMessage(response.body, 'Registration failed'));
    }
  }

  String _errorMessage(String body, String fallback) {
    final data = jsonDecode(body);
    if (data is Map<String, dynamic> && data.isNotEmpty) {
      final value = data.values.first;
      if (value is List && value.isNotEmpty) return value.first.toString();
      if (value is String) return value;
    }
    return fallback;
  }
}

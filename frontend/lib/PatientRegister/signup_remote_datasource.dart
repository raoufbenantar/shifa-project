
// ─────────────────────────────────────────────────────────────
// DATA LAYER → Remote Data Source
//
// WHY an abstract + mock pattern?
// Right now we mock the API call with a delay.
// When the real backend is ready, we create
// SignupRemoteDataSourceImpl that makes the actual
// http.post() call, and inject THAT instead –
// zero changes to Domain or Presentation layers.
// ─────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shifa/PatientRegister/signup_model.dart';
import 'package:shifa/core/api_config.dart';

abstract class SignupRemoteDataSource {
  Future<void> registerPatient(SignupModel model);
}

class SignupRemoteDataSourceMock implements SignupRemoteDataSource {
  @override
  Future<void> registerPatient(SignupModel model) async {
    // Simulates a 1-second network round trip.
    // Replace this body with:
    //
    //   final response = await http.post(
    //     Uri.parse('https://your-api.com/auth/register/patient'),
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode(model.toJson()),
    //   );
    //   if (response.statusCode != 201) {
    //     throw Exception(jsonDecode(response.body)['message']);
    //   }
    //
    await Future.delayed(const Duration(seconds: 1));

    // Uncomment to simulate a server-side error during testing:
    // throw Exception('Email already registered');
  }
}

class SignupRemoteDataSourceImpl implements SignupRemoteDataSource {
  final http.Client _client;

  SignupRemoteDataSourceImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<void> registerPatient(SignupModel model) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register/patient/'),
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

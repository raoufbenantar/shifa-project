
// ─────────────────────────────────────────────────────────────
// DATA LAYER → Doctor Signup Remote Data Source
//
// Same mock-first pattern used across all auth features.
// When the backend is ready:
//   1. Create DoctorSignupRemoteDataSourceImpl
//   2. Inject it instead of the mock inside DoctorSignupScreen
//   3. Zero changes to Domain or Presentation layers.
// ─────────────────────────────────────────────────────────────

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

import 'doctor_model.dart';

// ─────────────────────────────────────────────────────────────
// DATA LAYER → Doctor Login Remote Data Source
//
// Same mock-first pattern used for patient login and signup.
// When the backend is ready, create DoctorLoginRemoteDataSourceImpl
// that does the actual http.post() and inject it — zero changes
// needed in Domain or Presentation.
// ─────────────────────────────────────────────────────────────

abstract class DoctorLoginRemoteDataSource {
  Future<DoctorModel> loginDoctor({
    required String email,
    required String password,
  });
}

class DoctorLoginRemoteDataSourceMock implements DoctorLoginRemoteDataSource {
  @override
  Future<DoctorModel> loginDoctor({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // ── Simulate wrong credentials error ─────────────────
    // Uncomment to test DoctorLoginFailure state:
    // throw Exception('Invalid email or password.');

    // ── Simulate role mismatch (patient logs into doctor) ─
    // Uncomment to test role enforcement in the Use Case:
    // return DoctorModel.fromJson({ 'token': 'x',
    //   'user': { 'id': 1, 'email': email, 'role_id': 1,  ← patient!
    //   'is_active': true, 'profile': {...} } });

    // ── Happy-path: valid doctor response ────────────────
    // role_id = 2 → maps to roles.name = 'doctor'
    return DoctorModel.fromJson({
      'token': 'mock.jwt.token.doctor',
      'user': {
        'id':        2,
        'email':     email,
        'role_id':   2,         // MUST equal kDoctorRoleId
        'is_active': true,
        'profile': {
          'full_name':        'Dr. Ahmed Belkacem',
          'specialization':   'Cardiologist',
          'experience_years': 12,
          'consultation_fee': 2500.0,
          'bio':              'Senior cardiologist at Algiers Central Clinic.',
        },
      },
    });

    // ── Real implementation template ─────────────────────
    // final response = await http.post(
    //   Uri.parse('https://your-api.com/auth/login'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'email': email, 'password': password}),
    // );
    // if (response.statusCode == 200) {
    //   return DoctorModel.fromJson(jsonDecode(response.body));
    // }
    // throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
  }
}

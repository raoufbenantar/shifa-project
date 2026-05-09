
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

import 'package:shifa/PatientRegister/signup_model.dart';

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

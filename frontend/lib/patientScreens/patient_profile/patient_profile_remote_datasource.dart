import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import 'patient_profile_model.dart';

abstract class PatientProfileRemoteDataSource {
  Future<PatientProfileModel> getProfile();
  Future<PatientProfileModel> updateProfile(Map<String, dynamic> data);
}

class PatientProfileRemoteDataSourceImpl
    implements PatientProfileRemoteDataSource {
  final _client = ApiClient.instance;

  @override
  Future<PatientProfileModel> getProfile() async {
    final response = await _client.get(ApiConstants.patientProfile);

    if (response.statusCode == 200) {
      return PatientProfileModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to load profile: ${response.statusCode}');
  }

  @override
  Future<PatientProfileModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.patch(
      ApiConstants.patientProfile,
      body: data,
    );

    if (response.statusCode == 200) {
      return PatientProfileModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    final body = json.decode(response.body) as Map<String, dynamic>;
    final error = body.values.firstOrNull?.toString() ?? 'Update failed';
    throw Exception(error);
  }
}

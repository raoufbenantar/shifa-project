import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import 'patient_dashboard_model.dart';

abstract class PatientDashboardRemoteDataSource {
  Future<PatientDashboardModel> getPatientDashboard();
}

class PatientDashboardRemoteDataSourceImpl
    implements PatientDashboardRemoteDataSource {
  final _client = ApiClient.instance;

  @override
  Future<PatientDashboardModel> getPatientDashboard() async {
    final response = await _client.get(ApiConstants.patientDashboard);

    if (response.statusCode == 200) {
      return PatientDashboardModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load dashboard: ${response.statusCode}');
    }
  }
}

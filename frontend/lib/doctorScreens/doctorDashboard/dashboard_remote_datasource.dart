import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import 'dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardModel> getDashboard();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final _client = ApiClient.instance;

  @override
  Future<DashboardModel> getDashboard() async {
    final doctorId = await _client.getDoctorId();
    final params = <String, String>{};
    if (doctorId != null) params['doctor_id'] = '$doctorId';

    final response = await _client.get(
      ApiConstants.doctorDashboard,
      queryParams: params.isNotEmpty ? params : null,
    );

    if (response.statusCode == 200) {
      return DashboardModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load dashboard: ${response.statusCode}');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardModel> getDashboard();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  static const String _baseUrl = 'http://10.0.2.2:8000';

  @override
  Future<DashboardModel> getDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    final doctorId = prefs.getInt('doctor_id');

    final uri = doctorId != null
        ? Uri.parse('$_baseUrl/api/dashboard/doctor/?doctor_id=$doctorId')
        : Uri.parse('$_baseUrl/api/dashboard/doctor/');

    print('Fetching dashboard from: $uri');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Dashboard response: \${response.statusCode}');
    if (response.statusCode == 200) {
      return DashboardModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load dashboard: ${response.statusCode}');
    }
  }
}

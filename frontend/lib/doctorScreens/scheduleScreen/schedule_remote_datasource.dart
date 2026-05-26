import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import 'schedule_model.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<ScheduleAppointmentModel>> getAppointments();
  Future<void> confirmAppointment(int id);
  Future<void> rejectAppointment(int id);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final _client = ApiClient.instance;

  @override
  Future<List<ScheduleAppointmentModel>> getAppointments() async {
    final doctorId = await _client.getDoctorId();
    final params = <String, String>{};
    if (doctorId != null) params['doctor'] = '$doctorId';

    final response = await _client.get(ApiConstants.appointments,
        queryParams: params.isNotEmpty ? params : null);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data is List ? data : (data['results'] ?? []);
      return (list as List)
          .map((j) =>
              ScheduleAppointmentModel.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load appointments (${response.statusCode})');
  }

  @override
  Future<void> confirmAppointment(int id) async {
    final response = await _client
        .post('${ApiConstants.appointments}$id/confirm/');
    if (response.statusCode != 200) {
      throw Exception('Failed to confirm appointment');
    }
  }

  @override
  Future<void> rejectAppointment(int id) async {
    final response = await _client
        .post('${ApiConstants.appointments}$id/reject/');
    if (response.statusCode != 200) {
      throw Exception('Failed to reject appointment');
    }
  }
}

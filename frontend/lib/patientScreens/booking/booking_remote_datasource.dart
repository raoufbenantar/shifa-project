import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import 'booking_model.dart';

/// Abstract data source for the booking flow.
abstract class BookingRemoteDataSource {
  Future<List<DoctorModel>> getDoctors({String? search, String? specialization});
  Future<List<ClinicModel>> getClinics();
  Future<List<DoctorClinicModel>> getDoctorClinics(int doctorId);
  Future<List<AvailableSlotModel>> getAvailableSlots({
    required int doctorId,
    required int clinicId,
    required String date,
  });
  Future<PatientAppointmentModel> bookAppointment({
    required int doctorId,
    required int clinicId,
    required String scheduledDatetime,
    required String consultationType,
    String? notes,
  });
  Future<List<PatientAppointmentModel>> getMyAppointments();
  Future<void> cancelAppointment(int id);
  Future<PatientAppointmentModel> rescheduleAppointment(
      int id, String newDatetime);
}

/// Production implementation that talks to the real Django backend.
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final _client = ApiClient.instance;

  @override
  Future<List<DoctorModel>> getDoctors({
    String? search,
    String? specialization,
  }) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (specialization != null && specialization.isNotEmpty) {
      params['specialization'] = specialization;
    }

    final response = await _client.get(
      ApiConstants.doctors,
      queryParams: params.isNotEmpty ? params : null,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data is List ? data : (data['results'] ?? []);
      return (list as List)
          .map((j) => DoctorModel.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load doctors (${response.statusCode})');
  }

  @override
  Future<List<ClinicModel>> getClinics() async {
    final response = await _client.get(ApiConstants.clinics,
        queryParams: null);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data is List ? data : (data['results'] ?? []);
      return (list as List)
          .map((j) => ClinicModel.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load clinics (${response.statusCode})');
  }

  @override
  Future<List<DoctorClinicModel>> getDoctorClinics(int doctorId) async {
    final response = await _client.get(
      '${ApiConstants.doctors}$doctorId/',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final clinics = data['clinics'] as List? ?? [];
      return (clinics as List)
          .map((j) => DoctorClinicModel.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load doctor clinics (${response.statusCode})');
  }

  @override
  Future<List<AvailableSlotModel>> getAvailableSlots({
    required int doctorId,
    required int clinicId,
    required String date,
  }) async {
    final response = await _client.get(
      ApiConstants.availableSlots,
      queryParams: {
        'doctor': '$doctorId',
        'clinic': '$clinicId',
        'date': date,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final slots = data['slots'] as List? ?? [];
      return (slots as List)
          .map((j) => AvailableSlotModel.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load slots (${response.statusCode})');
  }

  @override
  Future<PatientAppointmentModel> bookAppointment({
    required int doctorId,
    required int clinicId,
    required String scheduledDatetime,
    required String consultationType,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'doctor': doctorId,
      'clinic': clinicId,
      'scheduled_datetime': scheduledDatetime,
      'consultation_type': consultationType,
    };
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;

    final response = await _client.post(
      ApiConstants.appointments,
      body: body,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return PatientAppointmentModel.fromJson(data);
    }

    // Try to parse validation errors
    final body2 = jsonDecode(response.body);
    final errorMsg = body2 is Map ? body2.toString() : 'Booking failed';
    throw Exception(errorMsg);
  }

  @override
  Future<List<PatientAppointmentModel>> getMyAppointments() async {
    final response = await _client.get(ApiConstants.appointments,
        queryParams: null);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data is List ? data : (data['results'] ?? []);
      return (list as List)
          .map((j) =>
              PatientAppointmentModel.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load appointments (${response.statusCode})');
  }

  @override
  Future<void> cancelAppointment(int id) async {
    final response = await _client
        .post('${ApiConstants.appointments}$id/cancel/');
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final msg = body is Map ? body.toString() : 'Cancellation failed';
      throw Exception(msg);
    }
  }

  @override
  Future<PatientAppointmentModel> rescheduleAppointment(
      int id, String newDatetime) async {
    final response = await _client.post(
      '${ApiConstants.appointments}$id/reschedule/',
      body: {'scheduled_datetime': newDatetime},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return PatientAppointmentModel.fromJson(data);
    }
    final body = jsonDecode(response.body);
    throw Exception(body is Map ? body.toString() : 'Reschedule failed');
  }
}

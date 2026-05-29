import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import 'medical_records_model.dart';

abstract class MedicalRecordsRemoteDataSource {
  Future<MedicalRecordModel?> getMedicalRecord();
}

class MedicalRecordsRemoteDataSourceImpl
    implements MedicalRecordsRemoteDataSource {
  final _client = ApiClient.instance;

  @override
  Future<MedicalRecordModel?> getMedicalRecord() async {
    final response = await _client.get(ApiConstants.medicalRecords);

    if (response.statusCode == 200) {
      final list = json.decode(response.body) as List;
      if (list.isEmpty) return null;
      return MedicalRecordModel.fromJson(
        list[0] as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to load medical record: ${response.statusCode}');
  }
}

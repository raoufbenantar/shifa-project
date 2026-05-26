import 'dart:convert';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import 'reviews_model.dart';

abstract class ReviewsRemoteDataSource {
  Future<List<ReviewModel>> getReviews();
}

class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final _client = ApiClient.instance;

  @override
  Future<List<ReviewModel>> getReviews() async {
    final doctorId = await _client.getDoctorId();
    final params = <String, String>{};
    if (doctorId != null) params['appointment__doctor'] = '$doctorId';

    final response = await _client.get(ApiConstants.reviews,
        queryParams: params.isNotEmpty ? params : null);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data is List ? data : (data['results'] ?? []);
      return (list as List)
          .map((j) => ReviewModel.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load reviews (${response.statusCode})');
  }
}

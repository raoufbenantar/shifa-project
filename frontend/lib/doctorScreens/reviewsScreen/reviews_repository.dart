import 'reviews_entity.dart';

abstract class ReviewsRepository {
  Future<List<ReviewEntity>> getReviews();
}

import 'reviews_entity.dart';
import 'reviews_repository.dart';

class GetReviewsUseCase {
  final ReviewsRepository _repo;
  GetReviewsUseCase(this._repo);
  Future<List<ReviewEntity>> call() => _repo.getReviews();
}

import 'reviews_entity.dart';
import 'reviews_remote_datasource.dart';
import 'reviews_repository.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDataSource _ds;
  ReviewsRepositoryImpl(this._ds);

  @override
  Future<List<ReviewEntity>> getReviews() => _ds.getReviews();
}

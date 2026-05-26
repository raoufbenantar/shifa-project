import 'package:flutter_bloc/flutter_bloc.dart';
import 'reviews_entity.dart';
import 'reviews_usecase.dart';

abstract class ReviewsState {}
class ReviewsInitial extends ReviewsState {}
class ReviewsLoading extends ReviewsState {}
class ReviewsLoaded extends ReviewsState {
  final List<ReviewEntity> list;
  ReviewsLoaded(this.list);

  double get avgWaiting => list.isEmpty
      ? 0.0
      : list.map((r) => r.ratingWaiting).reduce((a, b) => a + b) / list.length;

  double get avgHygiene => list.isEmpty
      ? 0.0
      : list.map((r) => r.ratingHygiene).reduce((a, b) => a + b) / list.length;

  double get avgAttentiveness => list.isEmpty
      ? 0.0
      : list.map((r) => r.ratingAttentiveness).reduce((a, b) => a + b) /
          list.length;

  double get overallAvg => list.isEmpty
      ? 0.0
      : list.map((r) => r.avgRating).reduce((a, b) => a + b) / list.length;
}
class ReviewsError extends ReviewsState {
  final String message;
  ReviewsError(this.message);
}

class ReviewsCubit extends Cubit<ReviewsState> {
  final GetReviewsUseCase _getReviews;

  ReviewsCubit(this._getReviews) : super(ReviewsInitial());

  Future<void> load() async {
    emit(ReviewsLoading());
    try {
      final list = await _getReviews();
      emit(ReviewsLoaded(list));
    } catch (e) {
      emit(ReviewsError(e.toString()));
    }
  }
}

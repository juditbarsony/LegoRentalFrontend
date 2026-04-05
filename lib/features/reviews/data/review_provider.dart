import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lego_rental_frontend/core/models/review_model.dart';
import 'package:lego_rental_frontend/features/auth/auth_providers.dart';
import 'package:lego_rental_frontend/features/reviews/data/review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

class ReviewState {
  final bool isLoading;
  final String? errorMessage;
  final List<ReviewModel> reviews;

  ReviewState({
    this.isLoading = false,
    this.errorMessage,
    this.reviews = const [],
  });

  ReviewState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ReviewModel>? reviews,
  }) {
    return ReviewState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      reviews: reviews ?? this.reviews,
    );
  }
}

class ReviewNotifier extends StateNotifier<ReviewState> {
  final ReviewRepository _repo;
  final Ref _ref;

  ReviewNotifier(this._repo, this._ref) : super(ReviewState());

  Future<void> loadUserReviews({required int userId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final token = _ref.read(authProvider).accessToken;
      if (token == null) throw Exception('No token.');

      final reviews = await _repo.getReviewsForUser(
        userId: userId,
        token: token,
      );

      state = state.copyWith(
        isLoading: false,
        reviews: reviews,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final reviewProvider =
    StateNotifierProvider<ReviewNotifier, ReviewState>((ref) {
  final repo = ref.watch(reviewRepositoryProvider);
  return ReviewNotifier(repo, ref);
});
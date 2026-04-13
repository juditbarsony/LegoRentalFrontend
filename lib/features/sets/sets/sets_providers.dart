import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lego_rental_frontend/core/models/lego_set_model.dart';
import 'package:lego_rental_frontend/features/auth/auth_providers.dart';
import 'package:lego_rental_frontend/features/sets/data/sets_repository.dart';

final setsRepositoryProvider = Provider<SetsRepository>((ref) {
  return SetsRepository();
});

class SetsState {
  final bool isLoading;
  final String? error;
  final List<LegoSetModel> items;

  const SetsState({
    this.isLoading = false,
    this.error,
    this.items = const [],
  });

  SetsState copyWith({
    bool? isLoading,
    String? error,
    List<LegoSetModel>? items,
  }) {
    return SetsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
    );
  }
}

class SetsNotifier extends StateNotifier<SetsState> {
  final SetsRepository _repo;
  final Ref _ref;

  SetsNotifier(this._repo, this._ref) : super(const SetsState());

  Future<void> loadSets({
    String? keyword,
    int? themeId,
    String? setStatus,
    String? location,
    double? maxPrice,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = _ref.read(authProvider).accessToken;
      if (token == null) throw Exception('Nincs access token');

      final sets = await _repo.loadSets(
        keyword: keyword,
        themeId: themeId,
        state: setStatus,
        location: location,
        maxPrice: maxPrice,
        token: token,
      );

      state = state.copyWith(
        isLoading: false,
        items: sets,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMySets() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = _ref.read(authProvider).accessToken;
      if (token == null) throw Exception('Nincs access token');

      final sets = await _repo.loadMySets(token: token);

      state = state.copyWith(
        isLoading: false,
        items: sets,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final setsProvider =
    StateNotifierProvider<SetsNotifier, SetsState>((ref) {
  final repo = ref.watch(setsRepositoryProvider);
  return SetsNotifier(repo, ref);
});
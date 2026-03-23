import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
//import 'package:lego_rental_frontend/features/auth/auth_providers.dart';
import 'package:lego_rental_frontend/core/models/lego_set_model.dart';
import 'package:lego_rental_frontend/features/sets/data/sets_repository.dart';

//import 'package:lego_rental_frontend/features/auth/auth_repository.dart'; // baseUrl miatt

// Repo provider
final setsRepositoryProvider = Provider<SetsRepository>((ref) {
  return SetsRepository();
});

// State
class SetsState {
  final bool isLoading;
  final String? error;
  final List<LegoSetModel> items;

  const SetsState({this.isLoading = false, this.error, this.items = const []});

  SetsState copyWith({
    bool? isLoading,
    String? error,
    List<LegoSetModel>? items,
  }) {
    return SetsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      items: items ?? this.items,
    );
  }
}

// Notifier
class SetsNotifier extends StateNotifier<SetsState> {
  SetsNotifier(this._repo) : super(const SetsState());

  final SetsRepository _repo;

  Future<void> loadSets({String? keyword, int? themeId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sets = await _repo.loadSets(keyword: keyword, themeId: themeId);
      state = state.copyWith(isLoading: false, items: sets);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Provider
final setsProvider = StateNotifierProvider<SetsNotifier, SetsState>((ref) {
  final repo = ref.watch(setsRepositoryProvider);
  return SetsNotifier(repo);
});

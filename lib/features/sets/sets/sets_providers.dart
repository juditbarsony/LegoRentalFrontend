import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lego_rental_frontend/features/auth/auth_providers.dart';
import 'package:lego_rental_frontend/features/sets/data/lego_set.dart';
import 'package:lego_rental_frontend/features/sets/data/sets_repository.dart';

//import 'package:lego_rental_frontend/features/auth/auth_repository.dart'; // baseUrl miatt

// Repo provider
final setsRepositoryProvider = Provider<SetsRepository>((ref) {
  const baseUrl = 'http://127.0.0.1:8000'; // nálad ami van
  return SetsRepository(baseUrl, ref: ref);
});

// State
class SetsState {
  final bool isLoading;
  final String? error;
  final List<LegoSet> items;

  const SetsState({this.isLoading = false, this.error, this.items = const []});

  SetsState copyWith({bool? isLoading, String? error, List<LegoSet>? items}) {
    return SetsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      items: items ?? this.items,
    );
  }
}

// Notifier
class SetsNotifier extends StateNotifier<SetsState> {
  SetsNotifier(this._repo, this._ref) : super(const SetsState());

  final SetsRepository _repo;
  final Ref _ref;

  Future<void> loadSets({String? keyword}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authState = _ref.read(authProvider);
      final token = authState.accessToken;
      if (token == null) {
        throw Exception('Nincs access token – jelentkezz be újra.');
      }

      final sets = await _repo.loadSets(
        keyword: keyword,
        token: token,
      );

      state = state.copyWith(isLoading: false, items: sets);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Provider
final setsProvider = StateNotifierProvider<SetsNotifier, SetsState>((ref) {
  final repo = ref.watch(setsRepositoryProvider);
  return SetsNotifier(repo, ref);
});

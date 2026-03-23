//import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lego_rental_frontend/features/auth/auth_providers.dart';
import 'package:lego_rental_frontend/core/models/lego_set_model.dart';
import 'package:lego_rental_frontend/features/sets/data/sets_repository.dart';
import 'package:lego_rental_frontend/features/sets/sets/sets_providers.dart'; // repo providerhez

class SetDetailState {
  final bool isLoading;
  final LegoSetModel? set;
  final String? errorMessage;

  SetDetailState({
    this.isLoading = false,
    this.set,
    this.errorMessage,
  });

  SetDetailState copyWith({
    bool? isLoading,
    LegoSetModel? set,
    String? errorMessage,
  }) {
    return SetDetailState(
      isLoading: isLoading ?? this.isLoading,
      set: set ?? this.set,
      errorMessage: errorMessage,
    );
  }
}

class SetDetailNotifier extends StateNotifier<SetDetailState> {
  final SetsRepository _repo;
  final Ref _ref;

  SetDetailNotifier(this._repo, this._ref) : super(SetDetailState());

  Future<void> load(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final authState = _ref.read(authProvider);
      final token = authState.accessToken;
      if (token == null) {
        throw Exception('Nincs access token – jelentkezz be újra.');
      }

      final result = await _repo.getSetById(id, token);
      state = SetDetailState(isLoading: false, set: result);
    } catch (e) {
      state = SetDetailState(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final setDetailProvider =
    StateNotifierProvider.autoDispose<SetDetailNotifier, SetDetailState>((ref) {
  final repo = ref.watch(setsRepositoryProvider);
  return SetDetailNotifier(repo, ref);
});

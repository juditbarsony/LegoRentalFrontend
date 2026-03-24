import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lego_rental_frontend/features/auth/auth_providers.dart';
import 'package:lego_rental_frontend/core/models/lego_set_model.dart';
import 'package:lego_rental_frontend/core/models/availability_model.dart';
import 'package:lego_rental_frontend/features/sets/data/sets_repository.dart';
import 'package:lego_rental_frontend/features/sets/sets/sets_providers.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class SetDetailState {
  final bool isLoading;
  final LegoSetModel? set;
  final List<AvailabilityModel> availabilities;
  final String? errorMessage;

  SetDetailState({
    this.isLoading = false,
    this.set,
    this.availabilities = const [],
    this.errorMessage,
  });

  SetDetailState copyWith({
    bool? isLoading,
    LegoSetModel? set,
    List<AvailabilityModel>? availabilities,
    String? errorMessage,
  }) {
    return SetDetailState(
      isLoading: isLoading ?? this.isLoading,
      set: set ?? this.set,
      availabilities: availabilities ?? this.availabilities,
      errorMessage: errorMessage,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class SetDetailNotifier extends StateNotifier<SetDetailState> {
  final SetsRepository repo;
  final Ref ref;

  SetDetailNotifier(this.repo, this.ref) : super(SetDetailState());

  Future<void> load(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final authState = ref.read(authProvider);
      final token = authState.accessToken;
      debugPrint('TOKEN: $token');
      debugPrint('SET ID: $id');
      if (token == null) {
        throw Exception('Nincs access token, jelentkezz be újra.');
      }
      final result = await repo.getSetById(id, token);
      final avails = await repo.getAvailabilities(id, token);
      state = SetDetailState(
        isLoading: false,
        set: result,
        availabilities: avails,
      );
    } catch (e) {
      state = SetDetailState(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final setDetailProvider =
    StateNotifierProvider<SetDetailNotifier, SetDetailState>((ref) {
  final repo = ref.watch(setsRepositoryProvider);
  return SetDetailNotifier(repo, ref);
});

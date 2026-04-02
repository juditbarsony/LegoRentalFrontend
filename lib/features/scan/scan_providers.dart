import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lego_rental_frontend/core/models/scan_models.dart';
import 'package:lego_rental_frontend/features/auth/auth_providers.dart';
import 'package:lego_rental_frontend/features/scan/data/scan_repository.dart';

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepository();
});

// ─── State ────────────────────────────────────────────────────────────────────

class ScanState {
  final bool isLoading;
  final String? errorMessage;
  final ScanSessionModel? session;
  final ScanIdentifyResult? lastResult;

  ScanState({
    this.isLoading = false,
    this.errorMessage,
    this.session,
    this.lastResult,
  });

  ScanState copyWith({
    bool? isLoading,
    String? errorMessage,
    ScanSessionModel? session,
    ScanIdentifyResult? lastResult,
  }) {
    return ScanState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      session: session ?? this.session,
      lastResult: lastResult ?? this.lastResult,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ScanNotifier extends StateNotifier<ScanState> {
  final ScanRepository _repo;
  final Ref _ref;

  ScanNotifier(this._repo, this._ref) : super(ScanState());

  Future<void> createSession({
    required int rentalId,
    required int legoSetId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final token = _ref.read(authProvider).accessToken;
      if (token == null) throw Exception('Nincs token.');
      final session = await _repo.createSession(
        rentalId: rentalId,
        legoSetId: legoSetId,
        token: token,
      );
      state = state.copyWith(isLoading: false, session: session);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> identifyAndMark({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    if (state.session == null) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final token = _ref.read(authProvider).accessToken;
      if (token == null) throw Exception('Nincs token.');

      // 1. Azonosítás
      final result = await _repo.identifyPart(
        imageBytes: imageBytes,
        fileName: fileName,
        token: token,
      );

      // 2. Elem megjelölése ha benne van a session-ben
      final sessionItems = state.session!.items;
      final match = sessionItems
          .where((i) => i.partNum == result.partNum && !i.identified)
          .isNotEmpty;

      ScanSessionModel updatedSession = state.session!;
      if (match) {
        updatedSession = await _repo.markItemIdentified(
          sessionId: state.session!.id,
          partNum: result.partNum,
          confidence: result.confidence,
          token: token,
        );
      }

      state = state.copyWith(
        isLoading: false,
        lastResult: result,
        session: updatedSession,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void reset() => state = ScanState();
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final scanProvider =
    StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  final repo = ref.watch(scanRepositoryProvider);
  return ScanNotifier(repo, ref);
});

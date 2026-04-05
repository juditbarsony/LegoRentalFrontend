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

      // 1. Azonosítás – visszaadja az összes felismert elemet
      final results = await _repo.identifyParts(
        sessionId: state.session!.id,
        imageBytes: imageBytes,
        fileName: fileName,
        token: token,
      );

      if (results.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // 2. Mark-batch – az összes találatot egyszerre küldi
      final updatedSession = await _repo.markBatch(
        sessionId: state.session!.id,
        elements: results,
        token: token,
      );

      // 3. Legjobb confidence-ű találat lesz a lastResult
      final best = results.reduce(
        (a, b) => a.confidence > b.confidence ? a : b,
      );

      state = state.copyWith(
        isLoading: false,
        lastResult: best,
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
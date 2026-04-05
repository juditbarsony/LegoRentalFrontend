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
  final List<ScanIdentifyResult> lastResults;

  ScanState({
    this.isLoading = false,
    this.errorMessage,
    this.session,
    this.lastResults = const [],
  });

  ScanState copyWith({
    bool? isLoading,
    String? errorMessage,
    ScanSessionModel? session,
    List<ScanIdentifyResult>? lastResults,
    bool clearError = false,
    bool clearSession = false,
    bool clearLastResults = false,
  }) {
    return ScanState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      session: clearSession ? null : (session ?? this.session),
      lastResults:
          clearLastResults ? const [] : (lastResults ?? this.lastResults),
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class ScanNotifier extends StateNotifier<ScanState> {
  final ScanRepository _repo;
  final Ref _ref;

  ScanNotifier(this._repo, this._ref) : super(ScanState());

  Future<String> _requireToken() async {
    final token = _ref.read(authProvider).accessToken;
    if (token == null) {
      throw Exception('Nincs token.');
    }
    return token;
  }

  Future<void> createSession({
    required int rentalId,
    required int legoSetId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearLastResults: true,
    );

    try {
      final token = await _requireToken();
      final session = await _repo.createSession(
        rentalId: rentalId,
        legoSetId: legoSetId,
        token: token,
      );

      state = state.copyWith(
        isLoading: false,
        session: session,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadOrCreateSession({
    required int rentalId,
    required int legoSetId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearLastResults: true,
    );

    try {
      final token = await _requireToken();

      final activeSession = await _repo.getActiveSession(
        rentalId: rentalId,
        token: token,
      );

      if (activeSession != null) {
        state = state.copyWith(
          isLoading: false,
          session: activeSession,
        );
        return;
      }

      final session = await _repo.createSession(
        rentalId: rentalId,
        legoSetId: legoSetId,
        token: token,
      );

      state = state.copyWith(
        isLoading: false,
        session: session,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadSession({
    required int sessionId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final token = await _requireToken();
      final session = await _repo.getSession(
        sessionId: sessionId,
        token: token,
      );

      state = state.copyWith(
        isLoading: false,
        session: session,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> identifyAndMark({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    if (state.session == null) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final token = await _requireToken();

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

      final updatedSession = await _repo.markBatch(
        sessionId: state.session!.id,
        elements: results,
        token: token,
      );

      state = state.copyWith(
        isLoading: false,
        lastResults: results,
        session: updatedSession,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> manualConfirm({
    required int itemId,
  }) async {
    if (state.session == null) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final token = await _requireToken();

      final updatedSession = await _repo.manualConfirmItem(
        sessionId: state.session!.id,
        itemId: itemId,
        token: token,
      );

      state = state.copyWith(
        isLoading: false,
        session: updatedSession,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> resetProgress() async {
    if (state.session == null) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearLastResults: true,
    );

    try {
      final token = await _requireToken();

      final updatedSession = await _repo.resetProgress(
        sessionId: state.session!.id,
        token: token,
      );

      state = state.copyWith(
        isLoading: false,
        session: updatedSession,
        clearLastResults: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> finishSession() async {
    if (state.session == null) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final token = await _requireToken();

      final updatedSession = await _repo.finishSession(
        sessionId: state.session!.id,
        token: token,
      );

      state = state.copyWith(
        isLoading: false,
        session: updatedSession,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = ScanState();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  final repo = ref.watch(scanRepositoryProvider);
  return ScanNotifier(repo, ref);
});
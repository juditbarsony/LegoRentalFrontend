import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lego_rental_frontend/core/models/lego_set_model.dart';
import 'package:lego_rental_frontend/features/auth/auth_providers.dart';
import 'package:lego_rental_frontend/features/sets/data/sets_repository.dart';
import 'package:lego_rental_frontend/features/sets/sets/sets_providers.dart';



class UploadState {
  final bool isLoading;
  final bool success;
  final String? errorMessage;

  UploadState({
    this.isLoading = false,
    this.success = false,
    this.errorMessage,
  });

  UploadState copyWith({
    bool? isLoading,
    bool? success,
    String? errorMessage,
  }) {
    return UploadState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      errorMessage: errorMessage,
    );
  }
}

class UploadNotifier extends StateNotifier<UploadState> {
  final SetsRepository repo;
  final Ref ref;

  UploadNotifier(this.repo, this.ref) : super(UploadState());

  Future<void> uploadSet({
    String? setNum,
    String? title,
    required String location,
    required double rentalPrice,
    required double deposit,
    required bool scanRequired,
    required bool isPublic,
    String? state,
    String? notes,
    List<String>? missingItems,
    List<Map<String, String>> availabilityPeriods = const [],
  }) async {
    this.state = UploadState(isLoading: true);
    try {
      final token = ref.read(authProvider).accessToken;
      if (token == null) throw Exception('No access token.');
      if (setNum == null && (title == null || title.isEmpty)) {
        throw Exception('Either Part Number or Title is required.');
      }

      final newSet = await repo.createSet(
        setNum: setNum,
        title: title,
        location: location,
        rentalPrice: rentalPrice,
        deposit: deposit,
        scanRequired: scanRequired,
        isPublic: isPublic,
        state: state,
        notes: notes,
        missingItems: missingItems,
        token: token,
      );

      // Availability periódusok feltöltése
      for (final period in availabilityPeriods) {
        await repo.addAvailability(
          setId: newSet.id,
          startDate: period['start_date']!,
          endDate: period['end_date']!,
          token: token,
        );
      }

      this.state = UploadState(isLoading: false, success: true);
    } catch (e) {
      this.state = UploadState(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = UploadState();
}

final uploadProvider =
    StateNotifierProvider<UploadNotifier, UploadState>((ref) {
  final repo = ref.watch(setsRepositoryProvider);
  return UploadNotifier(repo, ref);
});

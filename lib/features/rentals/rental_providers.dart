import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lego_rental_frontend/core/models/rental_model.dart';
import 'package:lego_rental_frontend/features/auth/auth_providers.dart';
import 'package:lego_rental_frontend/features/rentals/data/rental_repository.dart';


final rentalRepositoryProvider = Provider<RentalRepository>((ref) {
  return RentalRepository();
});

// ─── Create Rental State ──────────────────────────────────────────────────────

class CreateRentalState {
  final bool isLoading;
  final RentalModel? rental;
  final String? errorMessage;
  final bool success;

  CreateRentalState({
    this.isLoading = false,
    this.rental,
    this.errorMessage,
    this.success = false,
  });

  CreateRentalState copyWith({
    bool? isLoading,
    RentalModel? rental,
    String? errorMessage,
    bool? success,
  }) {
    return CreateRentalState(
      isLoading: isLoading ?? this.isLoading,
      rental: rental ?? this.rental,
      errorMessage: errorMessage,
      success: success ?? this.success,
    );
  }
}

class CreateRentalNotifier extends StateNotifier<CreateRentalState> {
  final RentalRepository repo;
  final Ref ref;

  CreateRentalNotifier(this.repo, this.ref) : super(CreateRentalState());

  Future<void> createRental({
    required int legoSetId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, success: false);
    try {
      final token = ref.read(authProvider).accessToken;
      if (token == null) throw Exception('Nincs access token.');
      final rental = await repo.createRental(
        legoSetId: legoSetId,
        startDate: startDate,
        endDate: endDate,
        token: token,
      );
      state = CreateRentalState(
        isLoading: false,
        rental: rental,
        success: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = CreateRentalState();
  }
}

final createRentalProvider =
    StateNotifierProvider<CreateRentalNotifier, CreateRentalState>((ref) {
  final repo = ref.watch(rentalRepositoryProvider);
  return CreateRentalNotifier(repo, ref);
});

// ─── My Rentals State ─────────────────────────────────────────────────────────

class MyRentalsState {
  final bool isLoading;
  final List<RentalModel> rentals;
  final String? errorMessage;

  MyRentalsState({
    this.isLoading = false,
    this.rentals = const [],
    this.errorMessage,
  });
}

class MyRentalsNotifier extends StateNotifier<MyRentalsState> {
  final RentalRepository _repo;
  final Ref _ref;

  MyRentalsNotifier(this._repo, this._ref) : super(MyRentalsState());

  Future<void> load() async {
    state = MyRentalsState(isLoading: true);
    try {
      final token = _ref.read(authProvider).accessToken;
      if (token == null) throw Exception('Nincs token.');
      final rentals = await _repo.getMyRentals(token);
      state = MyRentalsState(rentals: rentals);
    } catch (e) {
      state = MyRentalsState(errorMessage: e.toString());
    }
  }
}

final myRentalsProvider =
    StateNotifierProvider<MyRentalsNotifier, MyRentalsState>((ref) {
  final repo = ref.watch(rentalRepositoryProvider);
  return MyRentalsNotifier(repo, ref);
});

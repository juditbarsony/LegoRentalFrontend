import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lego_rental_frontend/features/auth/auth_repository.dart';
//import 'package:lego_rental_frontend/core/services/api_service.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final String? userName; // később rendes UserOut lesz
  final String? accessToken;
  final int? userId;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.userName,
    this.accessToken,
    this.userId,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? userName,
    String? accessToken,
    int? userId,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      userName: userName ?? this.userName,
      accessToken: accessToken ?? this.accessToken,
      userId: userId ?? this.userId,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token =
          await _authRepository.login(email: email, password: password);
      // await ApiService.saveToken(token);
      final userJson = await _authRepository.getCurrentUser(token);
      final userId = userJson['id'] as int?;
      final userName = userJson['full_name']?.toString() ??
          userJson['email']?.toString() ??
          email;

      state = state.copyWith(
        isLoading: false,
        error: null,
        userId: userId,
        userName: userName,
        accessToken: token,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lego_rental_frontend/features/auth/auth_repository.dart';


class AuthState {
  final bool isLoading;
  final String? error;
  final String? userName; // később rendes UserOut lesz
  final String? accessToken;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.userName,
    this.accessToken,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? userName,
    String? accessToken,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      userName: userName ?? this.userName,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}


class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = await _authRepository.login(email: email, password: password);

      final userJson = await _authRepository.getCurrentUser(token);
      final userName = userJson['full_name']?.toString() ?? userJson['email']?.toString() ?? email;

      state = state.copyWith(
        isLoading: false,
        accessToken: token,
        userName: userName,
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

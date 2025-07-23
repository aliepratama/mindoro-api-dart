import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth state enum
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

// Auth state class
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  factory AuthState.loading() {
    return const AuthState(status: AuthStatus.loading, isLoading: true);
  }

  factory AuthState.authenticated(User user) {
    return AuthState(status: AuthStatus.authenticated, user: user);
  }

  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  factory AuthState.error(String message) {
    return AuthState(status: AuthStatus.error, errorMessage: message);
  }

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Auth view model
class AuthViewModel extends StateNotifier<AuthState> {
  final SupabaseClient _client = Supabase.instance.client;

  AuthViewModel() : super(AuthState.initial()) {
    _initializeAuth();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session?.user != null) {
        state = AuthState.authenticated(session!.user);
      } else {
        state = AuthState.unauthenticated();
      }
    });
  }

  void _initializeAuth() async {
    try {
      final session = _client.auth.currentSession;
      if (session?.user != null) {
        state = AuthState.authenticated(session!.user);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error('Failed to initialize authentication: ${e.toString()}');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = AuthState.loading();

    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

      if (response.user != null) {
        state = AuthState.authenticated(response.user!);
      } else {
        state = AuthState.error('Registration failed: User creation failed');
      }
    } catch (e) {
      state = AuthState.error('Registration failed: ${e.toString()}');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = AuthState.authenticated(response.user!);
      } else {
        state = AuthState.error('Login failed: Invalid credentials');
      }
    } catch (e) {
      state = AuthState.error('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    state = AuthState.loading();

    try {
      await _client.auth.signOut();
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error('Logout failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true);

    try {
      await _client.auth.resetPasswordForEmail(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = AuthState.error('Password reset failed: ${e.toString()}');
    }
  }

  void clearError() {
    if (state.status == AuthStatus.error) {
      state = AuthState.unauthenticated();
    }
  }
}

// Providers
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel();
});

// Convenience providers
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authViewModelProvider);
  return authState.user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authViewModelProvider);
  return authState.status == AuthStatus.authenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authViewModelProvider);
  return authState.isLoading;
});

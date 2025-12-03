import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthUpdateProfile>(_onUpdateProfile);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event,
      Emitter<AuthState> emit
      ) async {
    emit(AuthLoading());
    await emit.forEach(
      authRepository.authStateChanges,
      onData: (user) {
        if (user != null) return Authenticated(user);
        return Unauthenticated();
      },
      onError: (error, stackTrace) => AuthError(error.toString()),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.email, event.password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.register(
        email: event.email,
        password: event.password,
        name: event.name,
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
      AuthUpdateProfile event,
      Emitter<AuthState> emit,
      ) async {
    final currentState = state;
    if (currentState is Authenticated) {
      try {
        emit(AuthLoading());

        await authRepository.updateUser(currentState.user.id, event.name, event.email);

        final updatedUser = UserEntity(
          id: currentState.user.id,
          email: event.email,
          name: event.name,
        );

        emit(Authenticated(updatedUser));
      } catch (e) {
        emit(AuthError("Failed to update profile: $e"));
        emit(Authenticated(currentState.user));
      }
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    emit(Unauthenticated());
  }
}

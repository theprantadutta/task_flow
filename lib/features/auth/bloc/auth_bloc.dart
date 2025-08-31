import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_flow/shared/models/user.dart';
import 'package:task_flow/shared/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(const AuthState.unknown()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthLoggedOut>(_onAuthLoggedOut);
    on<AuthError>(_onAuthError);
    on<AuthUserUpdated>(_onAuthUserUpdated);
    
    // Listen to auth state changes
    _authService.user.listen((user) {
      if (user != null) {
        add(AuthLoggedIn(user));
      } else {
        add(const AuthLoggedOut());
      }
    });
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) {
    // The state is already initialized as unknown in the constructor
    // This event is just to trigger the initial check
  }

  void _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    emit(AuthState.authenticated(event.user));
  }

  void _onAuthLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) {
    emit(const AuthState.unauthenticated());
  }

  void _onAuthError(AuthError event, Emitter<AuthState> emit) {
    emit(AuthState.error(event.message));
  }
  
  void _onAuthUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) {
    emit(AuthState.authenticated(event.user));
  }
}
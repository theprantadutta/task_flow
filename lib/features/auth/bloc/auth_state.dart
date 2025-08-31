part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final User? user;
  final AuthStatus status;
  final String? errorMessage;

  const AuthState._({
    this.user,
    required this.status,
    this.errorMessage,
  });

  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  const AuthState.authenticated(User user)
      : this._(user: user, status: AuthStatus.authenticated);

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  const AuthState.error(String message)
      : this._(status: AuthStatus.error, errorMessage: message);

  @override
  List<Object?> get props => [user, status, errorMessage];
}

enum AuthStatus { unknown, authenticated, unauthenticated, error }
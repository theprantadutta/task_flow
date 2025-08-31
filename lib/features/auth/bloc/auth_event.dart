part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthLoggedIn extends AuthEvent {
  final User user;

  const AuthLoggedIn(this.user);

  @override
  List<Object> get props => [user];
}

class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}

class AuthError extends AuthEvent {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class AuthUserUpdated extends AuthEvent {
  final User user;

  const AuthUserUpdated(this.user);

  @override
  List<Object> get props => [user];
}
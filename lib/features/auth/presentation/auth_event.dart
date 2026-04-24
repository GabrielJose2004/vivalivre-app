part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final String userId;
  const LoggedIn(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoggedOut extends AuthEvent {}

class AuthErrorOccurred extends AuthEvent {
  final String message;
  const AuthErrorOccurred(this.message);

  @override
  List<Object> get props => [message];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String username; // Assuming username is needed for registration

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  List<Object> get props => [email, password, username];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

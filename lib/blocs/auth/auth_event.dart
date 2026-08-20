part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class SignIn extends AuthEvent {
  final String userName;
  final String password;

  const SignIn({required this.userName, required this.password});

  @override
  List<Object?> get props => [userName, password];
}

class PostFCMToken extends AuthEvent {
  const PostFCMToken();

  @override
  List<Object?> get props => [];
}

class CheckUserRole extends AuthEvent {
  const CheckUserRole();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();

  @override
  List<Object?> get props => [];
}

class AutoSignIn extends AuthEvent {
  final String userName;
  final String password;

  const AutoSignIn({required this.userName, required this.password});

  @override
  List<Object?> get props => [userName, password];
}

class LogOut extends AuthEvent {
  const LogOut();

  @override
  List<Object?> get props => [];
}

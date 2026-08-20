part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final String errorMessage;
  final FormStatus formStatus;
  final AuthStatus authStatus;

  const AuthState({
    this.errorMessage = "",
    this.formStatus = FormStatus.pure,
    this.authStatus = AuthStatus.pure,
  });

  AuthState copyWith({
    String? errorMessage,
    FormStatus? formStatus,
    AuthStatus? authStatus,
  }) {
    return AuthState(
      errorMessage: errorMessage ?? this.errorMessage,
      formStatus: formStatus ?? this.formStatus,
      authStatus: authStatus ?? this.authStatus,
    );
  }

  @override
  List<Object?> get props => [errorMessage, formStatus, authStatus];
}

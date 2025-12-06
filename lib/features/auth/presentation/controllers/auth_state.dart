sealed class AuthState {}

class AuthInitialState extends AuthState {}

class AuthSuccessfullState extends AuthState {}

class AuthFailedState extends AuthState {
  final String message;

  AuthFailedState(this.message);
}

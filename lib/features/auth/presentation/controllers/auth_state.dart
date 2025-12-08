sealed class AuthState {}

class AuthInitialState extends AuthState {}

class AuthSuccessfullState extends AuthState {
  AuthSuccessfullState(this.message);
  final String message;
}

class AuthFailedState extends AuthState {
  AuthFailedState(this.message);
  final String message;
}

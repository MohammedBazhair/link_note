sealed class AuthState {
  const AuthState();
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthSuccessfullState extends AuthState {
  const AuthSuccessfullState();
}

class AuthFailedState extends AuthState {
  AuthFailedState(this.message);
  final String message;
}

sealed class AuthState {
  const AuthState();
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

enum AuthLoadingType { signWithGoogle, signWithEmail, signOut, resetPassword }

class AuthLoadingState extends AuthState {
  const AuthLoadingState(this.authLoadingType);
  final AuthLoadingType authLoadingType;
}

class AuthSuccessfullState extends AuthState {
  const AuthSuccessfullState();
}

class AuthSignOutState extends AuthState {
  const AuthSignOutState();
}

class AuthResetPasswordSuccessfullState extends AuthState {
  const AuthResetPasswordSuccessfullState(this.email);
  final String email;
}

class AuthPasswordChangedSuccessfullState extends AuthState {
  const AuthPasswordChangedSuccessfullState();
}

class AuthFailedState extends AuthState {
  AuthFailedState(this.message);
  final String message;
}

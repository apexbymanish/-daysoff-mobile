import '../api/models/auth_user.dart';

enum AuthStatus { unauthenticated, authenticated }

class AuthState {
  const AuthState(this.status, [this.user]);
  const AuthState.unauthenticated() : this(AuthStatus.unauthenticated);
  const AuthState.authenticated(AuthUser user)
      : this(AuthStatus.authenticated, user);

  final AuthStatus status;
  final AuthUser? user;

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

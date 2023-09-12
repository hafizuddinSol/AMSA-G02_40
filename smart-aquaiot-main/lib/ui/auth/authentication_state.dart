part of 'authentication_bloc.dart';

enum AuthState { firstRun, authenticated, unauthenticated }

class AuthenticationState {
  final AuthState authState;
  final User? user;
  final String? message;
  final String? roles; // Field to store the user's role

  const AuthenticationState._(this.authState, {this.user, this.message, this.roles});

  const AuthenticationState.authenticated(User user, String role) // Updated constructor with user's role
      : this._(AuthState.authenticated, user: user, roles: role);

  const AuthenticationState.unauthenticated({String? message})
      : this._(AuthState.unauthenticated,
            message: message ?? 'Unauthenticated');

  const AuthenticationState.onboarding() : this._(AuthState.firstRun);
}

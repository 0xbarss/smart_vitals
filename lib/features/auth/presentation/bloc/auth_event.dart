abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested(this.email, this.password);
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  AuthRegisterRequested({required this.email, required this.password, required this.name});
}

class AuthLogoutRequested extends AuthEvent {}
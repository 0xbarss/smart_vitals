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

class AuthUpdateProfile extends AuthEvent {
  final String name;
  final String email;
  AuthUpdateProfile({required this.name, required this.email});
}

class AuthLogoutRequested extends AuthEvent {}
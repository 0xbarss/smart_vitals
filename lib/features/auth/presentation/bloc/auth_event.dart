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

  AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
  });
}

class AuthUpdateProfile extends AuthEvent {
  final String name;
  final String email;
  final String emergencyEmail;
  final String emergencyPhone;
  final int age;
  final double weight;
  final double height;

  AuthUpdateProfile({
    required this.name,
    required this.email,
    required this.emergencyEmail,
    required this.emergencyPhone,
    required this.age,
    required this.weight,
    required this.height,
  });
}

class AuthLogoutRequested extends AuthEvent {}

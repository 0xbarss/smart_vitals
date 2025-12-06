import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? emergencyEmail;
  final String? emergencyPhone;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.emergencyEmail,
    this.emergencyPhone,
  });

  @override
  List<Object?> get props => [id, email, name, emergencyEmail, emergencyPhone];
}
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? emergencyEmail;
  final String? emergencyPhone;
  final int? age;
  final double? weight;
  final double? height;
  final double? diabetesRiskScore;
  final double? hypertensionRiskScore;
  final double? heartRiskScore;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.emergencyEmail,
    this.emergencyPhone,
    this.age,
    this.weight,
    this.height,
    this.diabetesRiskScore,
    this.hypertensionRiskScore,
    this.heartRiskScore,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    emergencyEmail,
    emergencyPhone,
    age,
    height,
    weight,
    diabetesRiskScore,
    hypertensionRiskScore,
    heartRiskScore,
  ];
}

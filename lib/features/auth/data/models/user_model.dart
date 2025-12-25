import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.emergencyEmail,
    super.emergencyPhone,
    super.age,
    super.height,
    super.weight,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      emergencyEmail: map['emergencyEmail'] ?? '',
      emergencyPhone: map['emergencyPhone'] ?? '',
      age: map['age'],
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'emergencyEmail': emergencyEmail,
      'emergencyPhone': emergencyPhone,
      'age': age,
      'height': height,
      'weight': weight,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

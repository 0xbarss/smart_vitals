import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<UserEntity> login(String email, String password);

  Future<void> register({
    required String email,
    required String password,
    required String name
  });

  Future<void> logout();
}
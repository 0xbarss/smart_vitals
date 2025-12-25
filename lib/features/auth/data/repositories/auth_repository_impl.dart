import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserEntity?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  Future<UserEntity> login(String email, String password) async {
    final userModel = await remoteDataSource.login(email, password);
    if (userModel == null) throw Exception("User not found");
    return userModel;
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) {
    return remoteDataSource.register(email, password, name);
  }

  @override
  Future<void> updateUser(
    String uid,
    String name,
    String email,
    String emergencyEmail,
    String emergencyPhone,
    int age,
    double weight,
    double height,
  ) async {
    await remoteDataSource.updateUserData(
      uid,
      name,
      email,
      emergencyEmail,
      emergencyPhone,
      age,
      weight,
      height,
    );
  }

  @override
  Future<void> logout() => remoteDataSource.logout();
}

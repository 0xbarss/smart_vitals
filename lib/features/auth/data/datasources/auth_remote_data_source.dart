import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;

  Future<UserModel?> login(String email, String password);

  Future<void> register(String email, String password, String name);

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return UserModel(id: user.uid, email: user.email ?? '');
    });
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      var user = userCredential.user;
      if (user == null) return null;

      var documentSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        return UserModel.fromMap(documentSnapshot.data()!);
      } else {
        return UserModel(id: user.uid, email: user.email!);
      }
    } catch (e) {
      throw Exception('Login Failed: $e');
    }
  }

  @override
  Future<void> register(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        UserModel newUser = UserModel(id: user.uid, email: email, name: name);

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }
    } catch (e) {
      throw Exception('Registration Failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}

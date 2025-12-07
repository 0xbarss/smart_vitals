import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class HealthRepository {
  Future<void> saveDailySteps(int steps);

  Future<int> getDailySteps(DateTime date);
}

class HealthRepositoryImpl implements HealthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  HealthRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<void> saveDailySteps(int steps) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final String dateId =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('daily_steps')
        .doc(dateId);

    await docRef.set({
      'steps': steps,
      'date': Timestamp.fromDate(now),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<int> getDailySteps(DateTime date) async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final String dateId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_steps')
          .doc(dateId)
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!['steps'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}

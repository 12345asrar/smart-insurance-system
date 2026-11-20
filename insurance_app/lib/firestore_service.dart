import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. إضافة مساهمة جديدة إلى مجموعة contributions
  Future<void> addContribution({
    required String memberName,
    required double amount,
    required String insuranceType,
    required String memberId,
  }) async {
    await _db.collection('contributions').add({
      'memberName': memberName,
      'memberId': memberId,
      'amount': amount,
      'insuranceType': insuranceType,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. الاستماع المباشر لجميع المساهمات لعرضها في القائمة
  Stream<QuerySnapshot<Map<String, dynamic>>> getContributionsStream() {
    return _db
        .collection('contributions')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 3. حذف مساهمة
  Future<void> deleteContribution(String docId) async {
    await _db.collection('contributions').doc(docId).delete();
  }

  // 4. حفظ بيانات مستخدم في مجموعة users
  Future<void> saveUserData({
    required String uid,
    required String name,
    required String email,
    required String role,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

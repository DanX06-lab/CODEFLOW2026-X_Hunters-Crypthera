import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CREATE USER DOCUMENT
  Future<void> createUser({
    required String uid,
    required String email,
    required String fullName,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'fullName': fullName,
      'email': email,
      'walletAddress': '',
      'vaultCreated': false,
      'isInactive': false,
      'beneficiaries': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // GET USER DATA
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  // GET USER STREAM FOR REAL-TIME UPDATES
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // UPDATE WALLET ADDRESS
  Future<void> updateWalletAddress(String uid, String walletAddress) async {
    await _firestore.collection('users').doc(uid).update({
      'walletAddress': walletAddress,
    });
  }

  // UPDATE VAULT CREATION STATUS
  Future<void> updateVaultCreated(String uid, bool vaultCreated) async {
    await _firestore.collection('users').doc(uid).update({
      'vaultCreated': vaultCreated,
    });
  }

  // UPDATE INACTIVITY STATUS
  Future<void> updateInactivityStatus(String uid, bool isInactive) async {
    await _firestore.collection('users').doc(uid).update({
      'isInactive': isInactive,
    });
  }

  // ADD BENEFICIARY
  Future<void> addBeneficiary(String uid, Map<String, dynamic> beneficiary) async {
    await _firestore.collection('users').doc(uid).update({
      'beneficiaries': FieldValue.arrayUnion([beneficiary]),
    });
  }

  // REMOVE BENEFICIARY
  Future<void> removeBeneficiary(String uid, Map<String, dynamic> beneficiary) async {
    await _firestore.collection('users').doc(uid).update({
      'beneficiaries': FieldValue.arrayRemove([beneficiary]),
    });
  }

  // ADD ACTIVITY LOG
  Future<void> addActivityLog(String uid, Map<String, dynamic> log) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('activityLogs')
        .add({
      ...log,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // GET ACTIVITY LOGS STREAM
  Stream<QuerySnapshot<Map<String, dynamic>>> getActivityLogsStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('activityLogs')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add user
  Future<void> addUser(
      String uid, String firstName, String lastName, String email) async {
    await _db.collection('users').doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    });
  }

  // Add IT user
  Future<void> addITUser(
      String uid, String firstName, String lastName, String id) async {
    await _db.collection('it_users').doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'id': id,
    });
  }

  // Add lab complaint
  Future<void> addLabComplaint(String lab, String instructorName,
      String instructorId, String pcNo, String complaint) async {
    await _db.collection('lab_complaints').add({
      'lab': lab,
      'instructorName': instructorName,
      'instructorId': instructorId,
      'pcNo': pcNo,
      'complaint': complaint,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Add classroom complaint
  Future<void> addClassroomComplaint(
      String name, String classNo, String complaint) async {
    await _db.collection('classroom_complaints').add({
      'name': name,
      'classNo': classNo,
      'complaint': complaint,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Add feedback form
  Future<void> addFeedbackForm(String userId) async {
    await _db.collection('feedbackForms').add({
      'userId': userId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get feedback forms
  Future<List<Map<String, dynamic>>> getFeedbackForms() async {
    final snapshot = await _db.collection('feedbackForms').get();
    return snapshot.docs
        .map((doc) => {
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            })
        .toList();
  }

  // Submit feedback
  Future<void> submitFeedback(
      String feedbackId, int rating, String suggestion) async {
    await _db.collection('feedbackForms').doc(feedbackId).update({
      'rating': rating,
      'suggestion': suggestion,
      'status': 'submitted',
    });
  }

  // Delete feedback
  Future<void> deleteFeedback(String feedbackId) async {
    await _db.collection('feedbackForms').doc(feedbackId).delete();
  }

  // Get lab complaints
  Future<List<Map<String, dynamic>>> getLabComplaints(String userId) async {
    QuerySnapshot snapshot = await _db.collection('lab_complaints').get();
    return snapshot.docs
        .map((doc) => {
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            })
        .toList();
  }

  // Get classroom complaints
  Future<List<Map<String, dynamic>>> getClassroomComplaints(String userId) async {
    QuerySnapshot snapshot = await _db.collection('classroom_complaints').get();
    return snapshot.docs
        .map((doc) => {
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            })
        .toList();
  }

  // Get user-specific lab complaints
  Future<List<Map<String, dynamic>>> getUserLabComplaints(String userId) async {
    QuerySnapshot snapshot = await _db
        .collection('lab_complaints')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => {
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            })
        .toList();
  }

  // Get user-specific classroom complaints
  Future<List<Map<String, dynamic>>> getUserClassroomComplaints(
      String userId) async {
    QuerySnapshot snapshot = await _db
        .collection('classroom_complaints')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => {
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            })
        .toList();
  }
}

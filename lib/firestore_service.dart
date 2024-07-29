import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add user
  Future<void> addUser(
      String uid, String firstName, String lastName, String email) async {
    try {
      await _db.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding user: $e');
      rethrow;
    }
  }

  // Add IT user
  Future<void> addITUser(
      String uid, String firstName, String lastName, String id) async {
    try {
      await _db.collection('it_users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'id': id,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding IT user: $e');
      rethrow;
    }
  }

  // Add lab complaint
  Future<void> addLabComplaint(String lab, String instructorName,
      String instructorId, String pcNo, String complaint) async {
    try {
      await _db.collection('lab_complaints').add({
        'lab': lab,
        'instructorName': instructorName,
        'instructorId': instructorId,
        'pcNo': pcNo,
        'complaint': complaint,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'unread',
      });
    } catch (e) {
      print('Error adding lab complaint: $e');
      rethrow;
    }
  }

  // Add classroom complaint
  Future<void> addClassroomComplaint(
      String name, String classNo, String complaint) async {
    try {
      await _db.collection('classroom_complaints').add({
        'name': name,
        'classNo': classNo,
        'complaint': complaint,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'unread',
      });
    } catch (e) {
      print('Error adding classroom complaint: $e');
      rethrow;
    }
  }

  // Add feedback form
  Future<void> addFeedbackForm(
      String userId, int rating, String comments) async {
    try {
      await _db.collection('feedbackForms').add({
        'userId': userId,
        'rating': rating,
        'comments': comments,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding feedback form: $e');
      rethrow;
    }
  }

  // Get feedback forms
  Future<List<Map<String, dynamic>>> getFeedbackForms() async {
    try {
      final snapshot = await _db.collection('feedbackForms').get();
      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      print('Error getting feedback forms: $e');
      rethrow;
    }
  }

  // Submit feedback
  Future<void> submitFeedback(
      String feedbackId, int rating, String comments) async {
    try {
      await _db.collection('feedbackForms').doc(feedbackId).update({
        'rating': rating,
        'comments': comments,
        'status': 'submitted',
      });
    } catch (e) {
      print('Error submitting feedback: $e');
      rethrow;
    }
  }

  // Delete feedback
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _db.collection('feedbackForms').doc(feedbackId).delete();
    } catch (e) {
      print('Error deleting feedback: $e');
      rethrow;
    }
  }

  // Get lab complaints
  Future<List<Map<String, dynamic>>> getLabComplaints(String userId) async {
    try {
      QuerySnapshot snapshot = await _db.collection('lab_complaints').get();
      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      print('Error getting lab complaints: $e');
      rethrow;
    }
  }

  // Get classroom complaints
  Future<List<Map<String, dynamic>>> getClassroomComplaints(
      String userId) async {
    try {
      QuerySnapshot snapshot =
          await _db.collection('classroom_complaints').get();
      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      print('Error getting classroom complaints: $e');
      rethrow;
    }
  }

  // Get user-specific lab complaints
  Future<List<Map<String, dynamic>>> getUserLabComplaints(String userId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('lab_complaints')
          .where('instructorId', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      print('Error getting user-specific lab complaints: $e');
      rethrow;
    }
  }

  // Get user-specific classroom complaints
  Future<List<Map<String, dynamic>>> getUserClassroomComplaints(
      String userId) async {
    try {
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
    } catch (e) {
      print('Error getting user-specific classroom complaints: $e');
      rethrow;
    }
  }

  // Clear all complaints for a user
  Future<void> clearComplaints(String userId) async {
    try {
      // Clear lab complaints
      QuerySnapshot labSnapshot = await _db
          .collection('lab_complaints')
          .where('instructorId', isEqualTo: userId)
          .get();
      // Clear classroom complaints
      QuerySnapshot classroomSnapshot = await _db
          .collection('classroom_complaints')
          .where('userId', isEqualTo: userId)
          .get();

      WriteBatch batch = _db.batch();

      for (QueryDocumentSnapshot doc in labSnapshot.docs) {
        batch.delete(doc.reference);
      }

      for (QueryDocumentSnapshot doc in classroomSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error clearing complaints: $e');
      rethrow;
    }
  }
}

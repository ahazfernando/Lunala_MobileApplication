import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

/// User Profile Service
/// Handles all user profile-related Firestore operations
class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();

  /// Get the currently logged-in user's ID
  /// Returns customer ID (e.g., CUST00001) or null if not logged in
  Future<String?> getCurrentUserId() async {
    try {
      // First try to get customer ID (most reliable)
      final customerId = await _firebaseService.getCurrentCustomerId();
      if (customerId != null && customerId.isNotEmpty) {
        return customerId;
      }

      // Fallback: Try to get phone number and look up customer
      final phoneNumber = await _firebaseService.getCurrentUserPhoneNumber();
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        final fullPhoneNumber = phoneNumber.startsWith('+') 
            ? phoneNumber 
            : '+94$phoneNumber';
        final customerData = await _firebaseService.getUserByPhoneNumber(fullPhoneNumber);
        if (customerData != null && customerData['id'] != null) {
          return customerData['id'] as String;
        }
      }

      return null;
    } catch (e) {
      print('UserProfileService: Error getting current user ID: $e');
      return null;
    }
  }

  /// Get user profile from Firestore users/{userId} collection
  /// Returns Map with user data or null if not found
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = await getCurrentUserId();
      
      if (userId == null || userId.isEmpty) {
        print('UserProfileService: No user ID available');
        return null;
      }

      print('UserProfileService: Fetching profile for userId: $userId');

      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        print('UserProfileService: Profile found with keys: ${data.keys}');
        return {'id': doc.id, ...data};
      } else {
        print('UserProfileService: Profile not found for userId: $userId');
        return null;
      }
    } catch (e) {
      print('UserProfileService: Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile in Firestore users/{userId} collection
  /// Updates firstName, lastName, and phoneNumber
  /// Returns true if successful, false otherwise
  Future<bool> updateUserProfile({
    required String firstName,
    required String lastName,
    String? email,
    required String phoneNumber,
  }) async {
    try {
      final userId = await getCurrentUserId();
      
      if (userId == null || userId.isEmpty) {
        print('UserProfileService: No user ID available for update');
        return false;
      }

      print('UserProfileService: Updating profile for userId: $userId');
      print('UserProfileService: firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber');

      // Prepare update data
      final updateData = <String, dynamic>{
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'phoneNumber': phoneNumber.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add email if provided
      if (email != null && email.trim().isNotEmpty) {
        updateData['email'] = email.trim();
      }

      // Update the document
      await _firestore
          .collection('users')
          .doc(userId)
          .set(updateData, SetOptions(merge: true));

      print('UserProfileService: Profile updated successfully');
      return true;
    } catch (e) {
      print('UserProfileService: Error updating user profile: $e');
      return false;
    }
  }

  /// Get user profile as a Stream (real-time updates)
  Stream<Map<String, dynamic>?> getUserProfileStream() {
    return Stream.fromFuture(getCurrentUserId()).asyncExpand((userId) {
      if (userId == null || userId.isEmpty) {
        print('UserProfileService: No user ID available for stream');
        return Stream.value(null);
      }

      print('UserProfileService: Creating stream for userId: $userId');

      return _firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .map((snapshot) {
            if (snapshot.exists) {
              final data = snapshot.data()!;
              return {'id': snapshot.id, ...data};
            }
            return null;
          });
    });
  }
}

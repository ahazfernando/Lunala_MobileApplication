import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Service for database operations
/// This service provides methods to interact with Firestore database
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================
  // AUTHENTICATION METHODS
  // ==========================

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Normalize phone number to extract just digits (removes +94, spaces, etc.)
  String _normalizePhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    return phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Extract phone number without country code (removes +94 prefix)
  String _extractPhoneNumberWithoutCountryCode(String phoneNumber) {
    final normalized = _normalizePhoneNumber(phoneNumber);
    // If it starts with 94, remove it (Sri Lanka country code)
    if (normalized.startsWith('94') && normalized.length > 9) {
      return normalized.substring(2);
    }
    return normalized;
  }

  /// Check if user exists in Firestore by phone number
  /// Handles both 'customers' collection and phone numbers stored as numbers or strings
  Future<bool> userExistsByPhoneNumber(String phoneNumber) async {
    try {
      // Normalize phone number - extract just digits without country code
      final normalizedPhone = _extractPhoneNumberWithoutCountryCode(phoneNumber);
      print('Checking user existence - Original: $phoneNumber, Normalized: $normalizedPhone');
      
      // Try querying as number first (since Firebase stores it as number)
      final phoneNumberAsInt = int.tryParse(normalizedPhone);
      
      if (phoneNumberAsInt != null) {
        print('Querying customers collection with phone number as int: $phoneNumberAsInt');
        // Query in 'customers' collection with number type
        final querySnapshotNumber = await _firestore
            .collection('customers')
            .where('phoneNumber', isEqualTo: phoneNumberAsInt)
            .limit(1)
            .get();
        
        if (querySnapshotNumber.docs.isNotEmpty) {
          print('User found in customers collection (as number)');
          return true;
        }
        
        // Also try as string in case some records are stored as strings
        print('Querying customers collection with phone number as string: $normalizedPhone');
        final querySnapshotString = await _firestore
            .collection('customers')
            .where('phoneNumber', isEqualTo: normalizedPhone)
            .limit(1)
            .get();
        
        if (querySnapshotString.docs.isNotEmpty) {
          print('User found in customers collection (as string)');
          return true;
        }
      }
      
      // Fallback: try in 'users' collection (for newly created users)
      print('Querying users collection with original phone number: $phoneNumber');
      final querySnapshotUsers = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      if (querySnapshotUsers.docs.isNotEmpty) {
        print('User found in users collection');
        return true;
      }
      
      print('User not found in any collection');
      return false;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  /// Get user by phone number
  /// Handles both 'customers' collection and phone numbers stored as numbers or strings
  Future<Map<String, dynamic>?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      // Normalize phone number - extract just digits without country code
      final normalizedPhone = _extractPhoneNumberWithoutCountryCode(phoneNumber);
      
      // Try querying as number first (since Firebase stores it as number)
      final phoneNumberAsInt = int.tryParse(normalizedPhone);
      
      if (phoneNumberAsInt != null) {
        // Query in 'customers' collection with number type
        final querySnapshotNumber = await _firestore
            .collection('customers')
            .where('phoneNumber', isEqualTo: phoneNumberAsInt)
            .limit(1)
            .get();
        
        if (querySnapshotNumber.docs.isNotEmpty) {
          final doc = querySnapshotNumber.docs.first;
          return {'id': doc.id, ...doc.data()};
        }
        
        // Also try as string in case some records are stored as strings
        final querySnapshotString = await _firestore
            .collection('customers')
            .where('phoneNumber', isEqualTo: normalizedPhone)
            .limit(1)
            .get();
        
        if (querySnapshotString.docs.isNotEmpty) {
          final doc = querySnapshotString.docs.first;
          return {'id': doc.id, ...doc.data()};
        }
      }
      
      // Fallback: try in 'users' collection (for newly created users)
      final querySnapshotUsers = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      if (querySnapshotUsers.docs.isNotEmpty) {
        final doc = querySnapshotUsers.docs.first;
        return {'id': doc.id, ...doc.data()};
      }
      
      return null;
    } catch (e) {
      print('Error getting user by phone number: $e');
      return null;
    }
  }

  /// Create a new user in Firestore
  Future<String?> createUser({
    required String phoneNumber,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      final userData = {
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (firstName != null && firstName.isNotEmpty) {
        userData['firstName'] = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        userData['lastName'] = lastName;
      }
      if (email != null && email.isNotEmpty) {
        userData['email'] = email;
      }

      final docRef = await _firestore.collection('users').add(userData);
      return docRef.id;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  /// Send OTP (for now, we'll use hardcoded 1234)
  /// In production, this would trigger Firebase Phone Auth
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      // For development: hardcoded OTP is 1234
      // In production, you would use:
      // await _auth.verifyPhoneNumber(
      //   phoneNumber: phoneNumber,
      //   verificationCompleted: (PhoneAuthCredential credential) {},
      //   verificationFailed: (FirebaseAuthException e) {},
      //   codeSent: (String verificationId, int? resendToken) {},
      //   codeAutoRetrievalTimeout: (String verificationId) {},
      // );
      return true;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  /// Verify OTP and authenticate user
  /// For now, accepts hardcoded OTP "1234"
  Future<bool> verifyOTPAndAuthenticate({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      // For development: hardcoded OTP is 1234
      if (otp != '1234') {
        return false;
      }

      // Check if user exists in Firestore
      final userExists = await userExistsByPhoneNumber(phoneNumber);
      
      if (!userExists) {
        // User doesn't exist, cannot login
        return false;
      }

      // Get user data from Firestore
      final userData = await getUserByPhoneNumber(phoneNumber);
      if (userData == null) {
        return false;
      }

      // In production, you would use Firebase Auth:
      // final credential = PhoneAuthProvider.credential(
      //   verificationId: verificationId,
      //   smsCode: otp,
      // );
      // await _auth.signInWithCredential(credential);
      
      // For now, we'll create a custom token or use anonymous auth
      // Since we're using hardcoded OTP, we'll just verify the user exists
      return true;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  /// Sign in with phone number (legacy method - kept for compatibility)
  Future<UserCredential?> signInWithPhoneNumber({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with phone: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ==========================
  // FIRESTORE METHODS - PRODUCTS
  // ==========================

  /// Get all products
  Stream<List<Map<String, dynamic>>> getProducts() {
    return _firestore
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// Get product by ID
  Future<Map<String, dynamic>?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  /// Add a new product
  Future<String?> addProduct(Map<String, dynamic> productData) async {
    try {
      final docRef = await _firestore.collection('products').add(productData);
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      return null;
    }
  }

  /// Update product
  Future<bool> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('products').doc(productId).update(updates);
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  /// Delete product
  Future<bool> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // ==========================
  // FIRESTORE METHODS - ORDERS
  // ==========================

  /// Get all orders for current user
  Stream<List<Map<String, dynamic>>> getUserOrders() {
    if (currentUser == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// Create a new order
  Future<String?> createOrder(Map<String, dynamic> orderData) async {
    try {
      if (currentUser != null) {
        orderData['userId'] = currentUser!.uid;
      }
      orderData['createdAt'] = FieldValue.serverTimestamp();
      orderData['status'] = 'pending';
      final docRef = await _firestore.collection('orders').add(orderData);
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  // ==========================
  // FIRESTORE METHODS - CART
  // ==========================

  /// Get user's cart
  Future<Map<String, dynamic>?> getCart() async {
    if (currentUser == null) return null;
    try {
      final doc = await _firestore
          .collection('carts')
          .doc(currentUser!.uid)
          .get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      print('Error getting cart: $e');
      return null;
    }
  }

  /// Add item to cart
  Future<bool> addToCart(String productId, int quantity) async {
    if (currentUser == null) return false;
    try {
      final cartRef = _firestore.collection('carts').doc(currentUser!.uid);
      final cartDoc = await cartRef.get();

      if (cartDoc.exists) {
        final cartData = cartDoc.data()!;
        final items = List<Map<String, dynamic>>.from(cartData['items'] ?? []);
        
        final existingItemIndex = items.indexWhere((item) => item['productId'] == productId);
        
        if (existingItemIndex >= 0) {
          items[existingItemIndex]['quantity'] = (items[existingItemIndex]['quantity'] as int) + quantity;
        } else {
          items.add({
            'productId': productId,
            'quantity': quantity,
            'addedAt': FieldValue.serverTimestamp(),
          });
        }

        await cartRef.update({
          'items': items,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await cartRef.set({
          'userId': currentUser!.uid,
          'items': [
            {
              'productId': productId,
              'quantity': quantity,
              'addedAt': FieldValue.serverTimestamp(),
            }
          ],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  /// Remove item from cart
  Future<bool> removeFromCart(String productId) async {
    if (currentUser == null) return false;
    try {
      final cartRef = _firestore.collection('carts').doc(currentUser!.uid);
      final cartDoc = await cartRef.get();

      if (cartDoc.exists) {
        final cartData = cartDoc.data()!;
        final items = List<Map<String, dynamic>>.from(cartData['items'] ?? [])
            .where((item) => item['productId'] != productId)
            .toList();

        await cartRef.update({
          'items': items,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  /// Clear cart
  Future<bool> clearCart() async {
    if (currentUser == null) return false;
    try {
      await _firestore.collection('carts').doc(currentUser!.uid).delete();
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  // ==========================
  // FIRESTORE METHODS - INVENTORY
  // ==========================

  /// Get inventory items
  Stream<List<Map<String, dynamic>>> getInventory() {
    return _firestore
        .collection('inventory')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  /// Update inventory stock
  Future<bool> updateInventoryStock(String productId, int newStock) async {
    try {
      await _firestore.collection('inventory').doc(productId).update({
        'stock': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating inventory: $e');
      return false;
    }
  }

  /// Get inventory item by product ID
  Future<Map<String, dynamic>?> getInventoryItem(String productId) async {
    try {
      final doc = await _firestore.collection('inventory').doc(productId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      print('Error getting inventory item: $e');
      return null;
    }
  }

  // ==========================
  // FIRESTORE METHODS - CATEGORIES
  // ==========================

  /// Get all categories
  Stream<List<Map<String, dynamic>>> getCategories() {
    return _firestore
        .collection('categories')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  // ==========================
  // FIRESTORE METHODS - USER PROFILE
  // ==========================

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    if (currentUser == null) return false;
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .set(profileData, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
}

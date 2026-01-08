import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          final customerData = {'id': doc.id, ...doc.data()};
          print('Found customer in customers collection: ${doc.id}, phoneNumber: $phoneNumberAsInt');
          print('Customer data: $customerData');
          return customerData;
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
      // Try with exact phone number (as stored, e.g., "+94795822412")
      final querySnapshotUsers = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      if (querySnapshotUsers.docs.isNotEmpty) {
        final doc = querySnapshotUsers.docs.first;
        print('Found user in users collection with exact phone: ${doc.id}');
        return {'id': doc.id, ...doc.data()};
      }
      
      // Try with + prefix if not already present
      if (!phoneNumber.startsWith('+')) {
        final phoneWithPlus = '+$phoneNumber';
        final querySnapshotUsersPlus = await _firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: phoneWithPlus)
            .limit(1)
            .get();
        
        if (querySnapshotUsersPlus.docs.isNotEmpty) {
          final doc = querySnapshotUsersPlus.docs.first;
          print('Found user in users collection with + prefix: ${doc.id}');
          return {'id': doc.id, ...doc.data()};
        }
      }
      
      // Try without + prefix if present
      if (phoneNumber.startsWith('+')) {
        final phoneWithoutPlus = phoneNumber.substring(1);
        final querySnapshotUsersNoPlus = await _firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: phoneWithoutPlus)
            .limit(1)
            .get();
        
        if (querySnapshotUsersNoPlus.docs.isNotEmpty) {
          final doc = querySnapshotUsersNoPlus.docs.first;
          print('Found user in users collection without + prefix: ${doc.id}');
          return {'id': doc.id, ...doc.data()};
        }
      }
      
      print('User not found in any collection for phone: $phoneNumber');
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
  /// Clears both Firebase Auth session and SharedPreferences
  Future<void> signOut() async {
    // Sign out from Firebase Auth
    await _auth.signOut();
    // Clear saved session from SharedPreferences
    await clearCurrentUserPhoneNumber();
    print('FirebaseService: User signed out and session cleared');
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

  /// Get orders by userId (document ID from users/customers collection)
  Future<List<Map<String, dynamic>>> getOrdersByUserId(String userId) async {
    try {
      // Try with orderBy first
      try {
        final querySnapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
        
        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data(),
                  })
              .toList();
        }
      } catch (e) {
        print('Query with orderBy failed (might need index): $e');
        // Fallback: try without orderBy
        try {
          final querySnapshot = await _firestore
              .collection('orders')
              .where('userId', isEqualTo: userId)
              .get();
          
          // Sort manually by createdAt
          final orders = querySnapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data(),
                  })
              .toList();
          
          // Sort by createdAt descending
          orders.sort((a, b) {
            final aDate = a['createdAt'];
            final bDate = b['createdAt'];
            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1;
            if (bDate == null) return -1;
            
            DateTime? aDateTime;
            DateTime? bDateTime;
            
            if (aDate is Timestamp) {
              aDateTime = aDate.toDate();
            } else if (aDate is DateTime) {
              aDateTime = aDate;
            }
            
            if (bDate is Timestamp) {
              bDateTime = bDate.toDate();
            } else if (bDate is DateTime) {
              bDateTime = bDate;
            }
            
            if (aDateTime == null && bDateTime == null) return 0;
            if (aDateTime == null) return 1;
            if (bDateTime == null) return -1;
            
            return bDateTime.compareTo(aDateTime);
          });
          
          return orders;
        } catch (e2) {
          print('Query without orderBy also failed: $e2');
        }
      }
      
      return [];
    } catch (e) {
      print('Error getting orders by userId: $e');
      return [];
    }
  }

  /// Get orders by phone number
  /// Tries multiple methods: direct phoneNumber field, userId field, or customerId field
  Future<List<Map<String, dynamic>>> getOrdersByPhoneNumber(String phoneNumber) async {
    try {
      // Normalize phone number first (remove any + or country code to match customers collection)
      final normalizedPhone = _extractPhoneNumberWithoutCountryCode(phoneNumber);
      print('Getting orders for phone number: $phoneNumber (normalized: $normalizedPhone)');
      
      // For querying orders by phoneNumber field (if it exists)
      final phoneWithoutPlus = normalizedPhone;
      
      // Method 1: Try to get orders directly by phoneNumber field (if orders have phoneNumber)
      // Try with + prefix
      try {
        final querySnapshot1 = await _firestore
            .collection('orders')
            .where('phoneNumber', isEqualTo: normalizedPhone)
            .get();
        
        if (querySnapshot1.docs.isNotEmpty) {
          print('Found ${querySnapshot1.docs.length} orders by phoneNumber field (with +)');
          return _sortOrdersByDate(querySnapshot1.docs);
        }
      } catch (e) {
        print('Query by phoneNumber with + failed: $e');
      }
      
      // Try without + prefix
      try {
        final querySnapshot1b = await _firestore
            .collection('orders')
            .where('phoneNumber', isEqualTo: phoneWithoutPlus)
            .get();
        
        if (querySnapshot1b.docs.isNotEmpty) {
          print('Found ${querySnapshot1b.docs.length} orders by phoneNumber field (without +)');
          return _sortOrdersByDate(querySnapshot1b.docs);
        }
      } catch (e) {
        print('Query by phoneNumber without + failed: $e');
      }

      // Method 2: Get customer by phone number, then get orders by userId
      // Use normalized phone number for customer lookup
      final customerData = await getUserByPhoneNumber(normalizedPhone);
      if (customerData != null && customerData['id'] != null) {
        // Use the customer's document ID (e.g., CUST00001) as the customerId
        final customerDocId = customerData['id'] as String; // Document ID (e.g., CUST00001)
        
        print('Found customer with document ID: $customerDocId');
        print('Customer data: $customerData');
        
        // PRIORITY: Query orders by userId field (this is how orders are linked to customers)
        // The order's userId field contains the customer's document ID (e.g., "CUST00001" or "CUSTO2375")
        try {
          print('Querying orders with userId: $customerDocId');
          
          // Try with orderBy first
          try {
            final querySnapshotUserId = await _firestore
                .collection('orders')
                .where('userId', isEqualTo: customerDocId)
                .orderBy('createdAt', descending: true)
                .get();
            
            if (querySnapshotUserId.docs.isNotEmpty) {
              print('Found ${querySnapshotUserId.docs.length} orders by userId: $customerDocId');
              return querySnapshotUserId.docs
                  .map((doc) => {
                        'id': doc.id,
                        ...doc.data(),
                      })
                  .toList();
            }
          } catch (e) {
            print('Query with orderBy failed (might need index): $e');
            // Fallback: try without orderBy
            try {
              final querySnapshotUserId = await _firestore
                  .collection('orders')
                  .where('userId', isEqualTo: customerDocId)
                  .get();
              
              if (querySnapshotUserId.docs.isNotEmpty) {
                print('Found ${querySnapshotUserId.docs.length} orders by userId (no orderBy): $customerDocId');
                return _sortOrdersByDate(querySnapshotUserId.docs);
              }
            } catch (e2) {
              print('Query without orderBy also failed: $e2');
            }
          }
          
          print('No orders found with userId: $customerDocId');
          // Debug: Check if any orders exist and what userId values they have
          try {
            final allOrdersCheck = await _firestore.collection('orders').limit(5).get();
            if (allOrdersCheck.docs.isNotEmpty) {
              print('Sample orders from database (checking userId values):');
              for (var doc in allOrdersCheck.docs) {
                final orderData = doc.data();
                print('Order ${doc.id} - userId: ${orderData['userId']}');
              }
            }
          } catch (e) {
            print('Error checking sample orders: $e');
          }
        } catch (e) {
          print('Error querying orders by userId: $e');
          print('This might be due to missing Firestore index. Check Firebase console for index creation link.');
        }
      } else {
        print('Customer not found for phone number: $phoneNumber');
      }

      // No orders found for this customer
      print('No orders found for customer with phone: $phoneNumber');
      return [];
    } catch (e) {
      print('Error getting orders by phone number: $e');
      return [];
    }
  }

  /// Helper method to sort orders by createdAt descending
  List<Map<String, dynamic>> _sortOrdersByDate(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final orders = docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();
    
    orders.sort((a, b) {
      final aDate = a['createdAt'];
      final bDate = b['createdAt'];
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      
      DateTime? aDateTime;
      DateTime? bDateTime;
      
      if (aDate is Timestamp) {
        aDateTime = aDate.toDate();
      } else if (aDate is DateTime) {
        aDateTime = aDate;
      }
      
      if (bDate is Timestamp) {
        bDateTime = bDate.toDate();
      } else if (bDate is DateTime) {
        bDateTime = bDate;
      }
      
      if (aDateTime == null && bDateTime == null) return 0;
      if (aDateTime == null) return 1;
      if (bDateTime == null) return -1;
      
      return bDateTime.compareTo(aDateTime);
    });
    
    return orders;
  }

  /// Stream orders by phone number (real-time updates)
  Stream<List<Map<String, dynamic>>> getOrdersByPhoneNumberStream(String phoneNumber) {
    try {
      // First, get the user by phone number synchronously
      return Stream.fromFuture(getUserByPhoneNumber(phoneNumber))
          .asyncExpand((userData) {
            if (userData == null || userData['id'] == null) {
              return Stream.value(<Map<String, dynamic>>[]);
            }

            final userId = userData['id'] as String;
            return _firestore
                .collection('orders')
                .where('userId', isEqualTo: userId)
                .orderBy('createdAt', descending: true)
                .snapshots()
                .map((snapshot) => snapshot.docs
                    .map((doc) => {
                          'id': doc.id,
                          ...doc.data(),
                        })
                    .toList());
          });
    } catch (e) {
      print('Error getting orders stream by phone number: $e');
      return Stream.value([]);
    }
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

  // ==========================
  // SHARED PREFERENCES - USER SESSION
  // ==========================

  // In-memory fallback storage if SharedPreferences fails
  static String? _cachedPhoneNumber;
  static String? _cachedCustomerId;

  /// Save current user's phone number to SharedPreferences
  /// Saves in the format that matches customers collection (normalized without country code)
  /// Also saves customer ID if available
  /// Uses in-memory cache as fallback if SharedPreferences fails
  Future<bool> saveCurrentUserPhoneNumber(String phoneNumber) async {
    try {
      print('=== SAVE PHONE NUMBER DEBUG ===');
      print('Attempting to save phone number: $phoneNumber');
      
      // Normalize phone number to match customers collection format (digits only, no country code)
      final normalizedPhone = _extractPhoneNumberWithoutCountryCode(phoneNumber);
      print('Normalized phone: $normalizedPhone');
      
      // Save to in-memory cache first (always works)
      _cachedPhoneNumber = normalizedPhone;
      print('Saved phone to memory cache: $normalizedPhone');
      
      SharedPreferences? prefs;
      bool sharedPrefsWorking = false;
      
      try {
        prefs = await SharedPreferences.getInstance();
        print('SharedPreferences instance obtained successfully');
        sharedPrefsWorking = true;
      } catch (e) {
        print('WARNING: Failed to get SharedPreferences instance: $e');
        print('Will use in-memory cache as fallback');
        sharedPrefsWorking = false;
      }
      
      // Try to save to SharedPreferences if available
      if (sharedPrefsWorking && prefs != null) {
        try {
          final phoneSaveSuccess = await prefs.setString('current_user_phone', normalizedPhone);
          print('Phone number save to SharedPreferences result: $phoneSaveSuccess');
          
          if (!phoneSaveSuccess) {
            print('WARNING: SharedPreferences setString returned false');
          }
        } catch (e) {
          print('ERROR saving phone number to SharedPreferences: $e');
          sharedPrefsWorking = false;
        }
      }
      
      // Also try to get and save customer ID directly
      try {
        print('Looking up customer for phone: $normalizedPhone');
        // Try multiple phone number formats to find the customer
        // First try with the original phone number format
        final customerData1 = await getUserByPhoneNumber(phoneNumber);
        Map<String, dynamic>? customerData = customerData1;
        
        // If not found, try with normalized phone
        if (customerData == null) {
          print('Trying with normalized phone: $normalizedPhone');
          customerData = await getUserByPhoneNumber(normalizedPhone);
        }
        
        // If still not found, try with full format
        if (customerData == null) {
          final fullPhoneNumber = phoneNumber.startsWith('+') ? phoneNumber : '+94$normalizedPhone';
          print('Trying with full phone: $fullPhoneNumber');
          customerData = await getUserByPhoneNumber(fullPhoneNumber);
        }
        
        if (customerData != null && customerData['id'] != null) {
          final customerId = customerData['id'] as String;
          print('Found customer ID: $customerId');
          
          // Save to memory cache
          _cachedCustomerId = customerId;
          print('Saved customer ID to memory cache: $customerId');
          
          // Try to save to SharedPreferences if available
          if (sharedPrefsWorking && prefs != null) {
            try {
              final idSaveSuccess = await prefs.setString('current_customer_id', customerId);
              print('FirebaseService: Saved customer ID to SharedPreferences: $customerId, success: $idSaveSuccess');
            } catch (e) {
              print('ERROR saving customer ID to SharedPreferences: $e');
            }
          }
        } else {
          print('FirebaseService: Customer not found for phone: $normalizedPhone');
        }
      } catch (e) {
        print('FirebaseService: Error looking up customer (continuing anyway): $e');
      }
      
      // Wait a bit to ensure SharedPreferences is written (if it's working)
      if (sharedPrefsWorking) {
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Verify both were saved
        if (prefs != null) {
          final verifyPhone = prefs.getString('current_user_phone');
          final verifyCustomerId = prefs.getString('current_customer_id');
          print('FirebaseService: Verification after save:');
          print('  Phone in SharedPreferences: $verifyPhone');
          print('  Customer ID in SharedPreferences: $verifyCustomerId');
        }
      }
      
      print('FirebaseService: Memory cache - Phone: $_cachedPhoneNumber, CustomerID: $_cachedCustomerId');
      
      // Return true if we saved to memory (always works) or SharedPreferences
      return true;
    } catch (e) {
      print('Error saving current user phone number: $e');
      print('Error stack: ${e.toString()}');
      // Even if there's an error, we have it in memory cache
      return _cachedPhoneNumber != null;
    }
  }

  /// Get current user's phone number from SharedPreferences or memory cache
  /// Returns the normalized phone number (digits only, no country code)
  /// Also tries to get customer ID if phone number is not available
  /// Falls back to in-memory cache if SharedPreferences fails
  Future<String?> getCurrentUserPhoneNumber() async {
    try {
      // First check memory cache (always works)
      if (_cachedPhoneNumber != null && _cachedPhoneNumber!.isNotEmpty) {
        print('FirebaseService: Retrieved phone number from memory cache: $_cachedPhoneNumber');
        return _cachedPhoneNumber;
      }
      
      // Try SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        
        // First try to get phone number
        var phoneNumber = prefs.getString('current_user_phone');
        print('FirebaseService: Retrieved phone number from SharedPreferences: ${phoneNumber ?? "null"}');
        
        // If phone number not found, try to get customer ID and look up phone
        if (phoneNumber == null || phoneNumber.isEmpty) {
          final customerId = prefs.getString('current_customer_id');
          print('FirebaseService: Phone number not found, checking customer ID: ${customerId ?? "null"}');
          
          if (customerId != null && customerId.isNotEmpty) {
            // Try to get customer by ID and extract phone number
            try {
              final customerDoc = await _firestore.collection('customers').doc(customerId).get();
              if (customerDoc.exists) {
                final customerData = customerDoc.data()!;
                final customerPhone = customerData['phoneNumber'];
                if (customerPhone != null) {
                  phoneNumber = customerPhone.toString();
                  print('FirebaseService: Retrieved phone from customer document: $phoneNumber');
                  // Save to memory cache
                  _cachedPhoneNumber = phoneNumber;
                  // Try to save to SharedPreferences
                  try {
                    await prefs.setString('current_user_phone', phoneNumber);
                  } catch (e) {
                    print('Could not save to SharedPreferences, but saved to memory cache');
                  }
                }
              }
            } catch (e) {
              print('Error getting customer by ID: $e');
            }
          }
        }
        
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          // Save to memory cache for future use
          _cachedPhoneNumber = phoneNumber;
          
          // Ensure it's normalized (no + prefix, just digits)
          final normalized = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
          // Remove country code if present (94 for Sri Lanka)
          final withoutCountryCode = normalized.startsWith('94') && normalized.length > 9
              ? normalized.substring(2)
              : normalized;
          print('FirebaseService: Normalized phone number: $withoutCountryCode');
          return withoutCountryCode;
        }
      } catch (e) {
        print('Error accessing SharedPreferences: $e');
        print('Will use memory cache if available');
      }
      
      // If we get here, neither SharedPreferences nor memory cache has it
      print('FirebaseService: Phone number is null or empty');
      return null;
    } catch (e) {
      print('Error getting current user phone number: $e');
      print('Error details: ${e.toString()}');
      // Return memory cache as last resort
      return _cachedPhoneNumber;
    }
  }

  /// Get current customer ID from SharedPreferences or memory cache
  /// Falls back to in-memory cache if SharedPreferences fails
  Future<String?> getCurrentCustomerId() async {
    try {
      // First check memory cache (always works)
      if (_cachedCustomerId != null && _cachedCustomerId!.isNotEmpty) {
        print('FirebaseService: Retrieved customer ID from memory cache: $_cachedCustomerId');
        return _cachedCustomerId;
      }
      
      // Try SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final customerId = prefs.getString('current_customer_id');
        print('FirebaseService: Retrieved customer ID from SharedPreferences: ${customerId ?? "null"}');
        
        if (customerId != null && customerId.isNotEmpty) {
          // Save to memory cache
          _cachedCustomerId = customerId;
          return customerId;
        }
        
        // Debug: List all keys if customer ID is null
        final allKeys = prefs.getKeys();
        print('FirebaseService: All SharedPreferences keys when customer ID is null: $allKeys');
        for (var key in allKeys) {
          print('FirebaseService: Key "$key" = ${prefs.get(key)}');
        }
      } catch (e) {
        print('Error accessing SharedPreferences: $e');
        print('Will use memory cache if available');
      }
      
      // Return memory cache as fallback
      return _cachedCustomerId;
    } catch (e) {
      print('Error getting current customer ID: $e');
      return _cachedCustomerId;
    }
  }
  
  /// Test if SharedPreferences is working by saving and reading a test value
  Future<bool> testSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const testKey = 'test_pref_key';
      const testValue = 'test_value_123';
      
      // Save test value
      final saveResult = await prefs.setString(testKey, testValue);
      print('Test save result: $saveResult');
      
      // Read it back
      final readValue = prefs.getString(testKey);
      print('Test read value: $readValue');
      
      // Clean up
      await prefs.remove(testKey);
      
      final isWorking = readValue == testValue;
      print('SharedPreferences test result: $isWorking');
      return isWorking;
    } catch (e) {
      print('SharedPreferences test failed: $e');
      return false;
    }
  }

  /// Get orders directly by customer ID (bypasses phone number lookup)
  Future<List<Map<String, dynamic>>> getOrdersByCustomerId(String customerId) async {
    try {
      print('Getting orders for customer ID: $customerId');
      
      // Try with orderBy first
      try {
        final querySnapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: customerId)
            .orderBy('createdAt', descending: true)
            .get();
        
        if (querySnapshot.docs.isNotEmpty) {
          print('Found ${querySnapshot.docs.length} orders by customerId: $customerId');
          return querySnapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data(),
                  })
              .toList();
        }
      } catch (e) {
        print('Query with orderBy failed: $e');
        // Fallback: try without orderBy
        try {
          final querySnapshot = await _firestore
              .collection('orders')
              .where('userId', isEqualTo: customerId)
              .get();
          
          if (querySnapshot.docs.isNotEmpty) {
            print('Found ${querySnapshot.docs.length} orders by customerId (no orderBy): $customerId');
            return _sortOrdersByDate(querySnapshot.docs);
          }
        } catch (e2) {
          print('Query without orderBy also failed: $e2');
        }
      }
      
      print('No orders found for customerId: $customerId');
      return [];
    } catch (e) {
      print('Error getting orders by customerId: $e');
      return [];
    }
  }

  /// Clear current user's phone number from SharedPreferences and memory cache (logout)
  Future<bool> clearCurrentUserPhoneNumber() async {
    try {
      // Clear memory cache
      _cachedPhoneNumber = null;
      _cachedCustomerId = null;
      print('FirebaseService: Cleared memory cache');
      
      // Try to clear SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('current_user_phone');
        await prefs.remove('current_customer_id');
        print('FirebaseService: Cleared SharedPreferences');
      } catch (e) {
        print('Warning: Could not clear SharedPreferences: $e');
        // Still return true since we cleared memory cache
      }
      
      return true;
    } catch (e) {
      print('Error clearing current user phone number: $e');
      // Clear memory cache anyway
      _cachedPhoneNumber = null;
      _cachedCustomerId = null;
      return false;
    }
  }
}

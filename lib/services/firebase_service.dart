// Firebase is currently disabled - uncomment below to re-enable
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Service for database operations
/// This service provides methods to interact with Firestore database
/// 
/// DISABLED: Firebase is not currently in use.
/// To re-enable:
/// 1. Uncomment the imports above
/// 2. Add Firebase dependencies back to pubspec.yaml
/// 3. Initialize Firebase in main.dart
/// 4. Uncomment the implementation below
class FirebaseService {
  // Firebase is disabled - this is a stub class
  // Uncomment the code below and restore imports to re-enable Firebase
  
  /*
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================
  // AUTHENTICATION METHODS
  // ==========================

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Sign in with phone number
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
  */
}

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order_model.dart';
import 'firebase_service.dart';

/// Order Service
/// Handles all order-related Firestore operations
class OrderService {
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
      print('Error getting current user ID: $e');
      return null;
    }
  }

  /// Get orders for the logged-in user as a Stream
  /// Automatically updates when orders change in Firestore
  /// Returns Stream<List<Order>> ordered by createdAt descending
  Stream<List<Order>> getUserOrdersStream() {
    return Stream.fromFuture(getCurrentUserId()).asyncExpand((userId) {
      if (userId == null || userId.isEmpty) {
        print('OrderService: No user ID available, returning empty stream');
        return Stream.value(<Order>[]);
      }

      print('OrderService: Fetching orders for userId: $userId');

      try {
        return _firestore
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) {
              final orders = snapshot.docs.map((doc) {
                try {
                  final data = doc.data();
                  return Order.fromFirestore(data, doc.id);
                } catch (e) {
                  print('Error parsing order ${doc.id}: $e');
                  return null;
                }
              }).whereType<Order>().toList();

              print('OrderService: Stream returned ${orders.length} orders');
              return orders;
            }).handleError((error) {
              print('OrderService: Stream error: $error');
              return <Order>[];
            });
      } catch (e) {
        print('OrderService: Error creating stream: $e');
        return Stream.value(<Order>[]);
      }
    });
  }

  /// Get orders for the logged-in user as a Future
  /// Returns List<Order> ordered by createdAt descending
  Future<List<Order>> getUserOrders() async {
    try {
      final userId = await getCurrentUserId();
      
      if (userId == null || userId.isEmpty) {
        print('OrderService: No user ID available');
        return [];
      }

      print('OrderService: Fetching orders for userId: $userId');

      // Try with orderBy first (requires Firestore index)
      try {
        final querySnapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final orders = querySnapshot.docs.map((doc) {
            try {
              final data = doc.data();
              return Order.fromFirestore(data, doc.id);
            } catch (e) {
              print('Error parsing order ${doc.id}: $e');
              return null;
            }
          }).whereType<Order>().toList();

          print('OrderService: Retrieved ${orders.length} orders');
          return orders;
        }
      } catch (e) {
        // If orderBy fails (index might not exist), try without it
        print('OrderService: Query with orderBy failed: $e');
        print('OrderService: Falling back to query without orderBy');
        
        try {
          final querySnapshot = await _firestore
              .collection('orders')
              .where('userId', isEqualTo: userId)
              .get();

          // Sort manually by createdAt descending
          final orders = querySnapshot.docs.map((doc) {
            try {
              final data = doc.data();
              return Order.fromFirestore(data, doc.id);
            } catch (e) {
              print('Error parsing order ${doc.id}: $e');
              return null;
            }
          }).whereType<Order>().toList();

          // Sort by createdAt descending
          orders.sort((a, b) {
            final aDate = a.createdAt ?? DateTime(1970);
            final bDate = b.createdAt ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });

          print('OrderService: Retrieved ${orders.length} orders (manually sorted)');
          return orders;
        } catch (e2) {
          print('OrderService: Query without orderBy also failed: $e2');
          return [];
        }
      }

      return [];
    } catch (e) {
      print('OrderService: Error getting user orders: $e');
      return [];
    }
  }

  /// Get a single order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return Order.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting order by ID: $e');
      return null;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Order Model
/// Represents an order in the system
class Order {
  final String? id;
  final String userId; // Can be empty if order doesn't have user linking
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // pending, confirmed, processing, shipped, delivered, cancelled
  final String? deliveryAddress;
  final DateTime? scheduledDate;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    this.id,
    this.userId = '', // Made optional with default empty string
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    this.deliveryAddress,
    this.scheduledDate,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  /// Helper method to convert Firestore timestamp to DateTime
  static DateTime? _timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is DateTime) {
      return timestamp;
    }
    return null;
  }

  /// Create Order from Firestore document
  factory Order.fromFirestore(Map<String, dynamic> data, String id) {
    // Try to get userId from various possible fields
    String userId = '';
    if (data['userId'] != null) {
      userId = data['userId'].toString();
    } else if (data['customerId'] != null) {
      userId = data['customerId'].toString();
    } else if (data['phoneNumber'] != null) {
      userId = data['phoneNumber'].toString();
    }

    // Calculate totalAmount from items if not present
    double totalAmount = (data['totalAmount'] ?? 0).toDouble();
    if (totalAmount == 0 && data['items'] != null) {
      final items = data['items'] as List<dynamic>?;
      if (items != null) {
        totalAmount = items.fold<double>(0.0, (sum, item) {
          if (item is Map<String, dynamic>) {
            return sum + ((item['totalPrice'] ?? item['price'] ?? 0) as num).toDouble();
          }
          return sum;
        });
      }
    }

    // Determine status - if not present, infer from channel or default to 'delivered' for in-store
    String status = data['status']?.toString() ?? 
                    data['orderStatus']?.toString() ?? 
                    '';
    
    if (status.isEmpty) {
      // If no status, infer from channel
      final channelValue = data['channel'];
      final channel = channelValue != null ? channelValue.toString().toLowerCase() : '';
      if (channel == 'in-store') {
        status = 'delivered'; // In-store orders are typically completed
      } else {
        status = 'pending'; // Default for other channels
      }
    }

    return Order(
      id: id,
      userId: userId,
      items: (data['items'] as List<dynamic>?)
              ?.map((item) {
                try {
                  return OrderItem.fromMap(item as Map<String, dynamic>);
                } catch (e) {
                  print('Error parsing order item: $e');
                  print('Item data: $item');
                  return null;
                }
              })
              .whereType<OrderItem>()
              .toList() ??
          [],
      totalAmount: totalAmount,
      status: status,
      deliveryAddress: data['deliveryAddress']?.toString(),
      scheduledDate: _timestampToDateTime(data['scheduledDate']),
      note: data['note']?.toString(),
      createdAt: _timestampToDateTime(data['createdAt']),
      updatedAt: _timestampToDateTime(data['updatedAt']),
    );
  }

  /// Convert Order to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      if (scheduledDate != null) 'scheduledDate': scheduledDate,
      if (note != null) 'note': note,
    };
  }
}

/// Order Item Model
/// Represents an item within an order
class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  /// Create OrderItem from Map
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    // Handle different price field names (unitPrice, price, totalPrice)
    double price = 0.0;
    if (map['unitPrice'] != null) {
      price = (map['unitPrice'] as num).toDouble();
    } else if (map['price'] != null) {
      price = (map['price'] as num).toDouble();
    } else if (map['totalPrice'] != null && map['quantity'] != null) {
      // Calculate unit price from totalPrice and quantity
      final totalPrice = (map['totalPrice'] as num).toDouble();
      final qty = (map['quantity'] as num).toInt();
      price = qty > 0 ? totalPrice / qty : 0.0;
    }

    return OrderItem(
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? map['name']?.toString() ?? '',
      quantity: (map['quantity'] ?? 0) as int,
      price: price,
    );
  }

  /// Convert OrderItem to Map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  /// Calculate total for this item
  double get total => quantity * price;
}











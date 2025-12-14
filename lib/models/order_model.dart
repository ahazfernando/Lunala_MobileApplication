/// Order Model
/// Represents an order in the system
class Order {
  final String? id;
  final String userId;
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
    required this.userId,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    this.deliveryAddress,
    this.scheduledDate,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Order from Firestore document
  factory Order.fromFirestore(Map<String, dynamic> data, String id) {
    return Order(
      id: id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      deliveryAddress: data['deliveryAddress'],
      scheduledDate: data['scheduledDate']?.toDate(),
      note: data['note'],
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
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
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
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










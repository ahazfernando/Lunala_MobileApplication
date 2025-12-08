/// Cart Item Model
/// Represents an item in the shopping cart
class CartItem {
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
  });

  /// Create CartItem from Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'],
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
    );
  }

  /// Convert CartItem to Map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      if (productImage != null) 'productImage': productImage,
      'price': price,
      'quantity': quantity,
    };
  }

  /// Calculate total for this item
  double get total => quantity * price;

  /// Create a copy with updated quantity
  CartItem copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}


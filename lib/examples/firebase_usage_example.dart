/// Example usage of FirebaseService
/// This file demonstrates how to use the Firebase service in your screens
/// 
/// Note: This is an example file and should not be imported in production code.
/// Use these patterns in your actual screen files.

import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class FirebaseUsageExample extends StatefulWidget {
  const FirebaseUsageExample({super.key});

  @override
  State<FirebaseUsageExample> createState() => _FirebaseUsageExampleState();
}

class _FirebaseUsageExampleState extends State<FirebaseUsageExample> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Usage Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProductsExample(),
          const SizedBox(height: 20),
          _buildOrdersExample(),
          const SizedBox(height: 20),
          _buildCartExample(),
        ],
      ),
    );
  }

  // ==========================
  // PRODUCTS EXAMPLE
  // ==========================
  Widget _buildProductsExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Products Example',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        
        // StreamBuilder for real-time product updates
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firebaseService.getProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No products found');
            }
            
            return Column(
              children: snapshot.data!.map((productData) {
                final product = Product.fromFirestore(
                  productData,
                  productData['id'] as String,
                );
                
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                  trailing: Text('Stock: ${product.stock}'),
                );
              }).toList(),
            );
          },
        ),
        
        const SizedBox(height: 10),
        
        // Example: Add a new product
        ElevatedButton(
          onPressed: () => _addProductExample(),
          child: const Text('Add Product Example'),
        ),
      ],
    );
  }

  Future<void> _addProductExample() async {
    final productData = {
      'name': 'Example Product',
      'description': 'This is an example product',
      'price': 19.99,
      'imageUrl': 'https://example.com/image.png',
      'category': 'Electronics',
      'stock': 100,
      'isAvailable': true,
    };
    
    final productId = await _firebaseService.addProduct(productData);
    if (productId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product added with ID: $productId')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add product')),
      );
    }
  }

  // ==========================
  // ORDERS EXAMPLE
  // ==========================
  Widget _buildOrdersExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Orders Example',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        
        // StreamBuilder for real-time order updates
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firebaseService.getUserOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No orders found');
            }
            
            return Column(
              children: snapshot.data!.map((orderData) {
                final order = Order.fromFirestore(
                  orderData,
                  orderData['id'] as String,
                );
                
                return ListTile(
                  title: Text('Order #${order.id}'),
                  subtitle: Text('Status: ${order.status}'),
                  trailing: Text('\$${order.totalAmount.toStringAsFixed(2)}'),
                );
              }).toList(),
            );
          },
        ),
        
        const SizedBox(height: 10),
        
        // Example: Create a new order
        ElevatedButton(
          onPressed: () => _createOrderExample(),
          child: const Text('Create Order Example'),
        ),
      ],
    );
  }

  Future<void> _createOrderExample() async {
    final orderData = {
      'items': [
        {
          'productId': 'product123',
          'productName': 'Example Product',
          'quantity': 2,
          'price': 19.99,
        }
      ],
      'totalAmount': 39.98,
      'deliveryAddress': '123 Main St, City, Country',
      'note': 'Please deliver in the morning',
    };
    
    final orderId = await _firebaseService.createOrder(orderData);
    if (orderId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order created with ID: $orderId')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create order')),
      );
    }
  }

  // ==========================
  // CART EXAMPLE
  // ==========================
  Widget _buildCartExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cart Example',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        
        // Get cart data
        FutureBuilder<Map<String, dynamic>?>(
          future: _firebaseService.getCart(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            
            if (!snapshot.hasData) {
              return const Text('Cart is empty');
            }
            
            final cart = snapshot.data!;
            final items = cart['items'] as List<dynamic>? ?? [];
            
            return Column(
              children: items.map((item) {
                return ListTile(
                  title: Text('Product ID: ${item['productId']}'),
                  subtitle: Text('Quantity: ${item['quantity']}'),
                );
              }).toList(),
            );
          },
        ),
        
        const SizedBox(height: 10),
        
        // Example: Add item to cart
        ElevatedButton(
          onPressed: () => _addToCartExample(),
          child: const Text('Add to Cart Example'),
        ),
        
        const SizedBox(height: 10),
        
        // Example: Clear cart
        ElevatedButton(
          onPressed: () => _clearCartExample(),
          child: const Text('Clear Cart Example'),
        ),
      ],
    );
  }

  Future<void> _addToCartExample() async {
    final success = await _firebaseService.addToCart('product123', 1);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added to cart')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add item to cart')),
      );
    }
  }

  Future<void> _clearCartExample() async {
    final success = await _firebaseService.clearCart();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart cleared')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to clear cart')),
      );
    }
  }
}

// ==========================
// USAGE IN YOUR SCREENS
// ==========================

/// Example: Using FirebaseService in HomeScreen
/// 
/// 1. Create an instance:
///    final FirebaseService _firebaseService = FirebaseService();
/// 
/// 2. Use StreamBuilder for real-time data:
///    StreamBuilder<List<Map<String, dynamic>>>(
///      stream: _firebaseService.getProducts(),
///      builder: (context, snapshot) {
///        // Handle loading, error, and data states
///      },
///    )
/// 
/// 3. Use FutureBuilder for one-time data:
///    FutureBuilder<Map<String, dynamic>?>(
///      future: _firebaseService.getProduct('productId'),
///      builder: (context, snapshot) {
///        // Handle loading, error, and data states
///      },
///    )
/// 
/// 4. Call methods for mutations:
///    await _firebaseService.addToCart('productId', 1);
///    await _firebaseService.createOrder(orderData);
///    await _firebaseService.updateProduct('productId', updates);



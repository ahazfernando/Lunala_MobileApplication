# Order Service - User Order History

## Overview

The `OrderService` provides a clean, production-ready way to fetch and display a logged-in user's order history from Firestore.

## Features

✅ Gets the currently logged-in user's ID (customer ID or UID)  
✅ Queries Firestore `orders` collection where `userId == loggedInUserId`  
✅ Orders results by `createdAt` descending  
✅ Returns data as `List<Order>`  
✅ Handles loading, empty, and error states  
✅ Provides both StreamBuilder and FutureBuilder approaches  
✅ Automatic fallback if Firestore index is missing  

## Firestore Structure

```
orders/
  {orderId}/
    userId: "CUST00001" (or user UID)
    items: [...]
    totalAmount: 1500.00
    status: "delivered"
    createdAt: Timestamp
    updatedAt: Timestamp
    ...
```

## Usage

### 1. Import the Service

```dart
import '../services/order_service.dart';
import '../models/order_model.dart';
```

### 2. Initialize the Service

```dart
final OrderService _orderService = OrderService();
```

### 3. Get User ID (if needed separately)

```dart
final userId = await _orderService.getCurrentUserId();
// Returns: "CUST00001" or null if not logged in
```

### 4. Option A: Using StreamBuilder (Real-time Updates)

```dart
StreamBuilder<List<Order>>(
  stream: _orderService.getUserOrdersStream(),
  builder: (context, snapshot) {
    // Loading state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    
    // Error state
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    
    // Get orders
    final orders = snapshot.data ?? [];
    
    // Empty state
    if (orders.isEmpty) {
      return const Text('No orders found');
    }
    
    // Display orders
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return ListTile(
          title: Text('Order ${order.id}'),
          subtitle: Text('Total: ${order.totalAmount}'),
        );
      },
    );
  },
)
```

### 5. Option B: Using FutureBuilder (One-time Load)

```dart
FutureBuilder<List<Order>>(
  future: _orderService.getUserOrders(),
  builder: (context, snapshot) {
    // Loading state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    
    // Error state
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    
    // Get orders
    final orders = snapshot.data ?? [];
    
    // Empty state
    if (orders.isEmpty) {
      return const Text('No orders found');
    }
    
    // Display orders
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return ListTile(
          title: Text('Order ${order.id}'),
          subtitle: Text('Total: ${order.totalAmount}'),
        );
      },
    );
  },
)
```

## Order Model Structure

The `Order` model includes:

```dart
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
}
```

## Firestore Mapping

The `Order.fromFirestore()` method handles:

- ✅ Timestamp to DateTime conversion
- ✅ Multiple userId field names (`userId`, `customerId`, `phoneNumber`)
- ✅ Multiple status field names (`status`, `orderStatus`)
- ✅ Calculates totalAmount from items if missing
- ✅ Handles missing or null fields gracefully

## Error Handling

The service handles:

- ✅ User not logged in (returns empty list)
- ✅ No orders found (returns empty list)
- ✅ Firestore index missing (falls back to manual sorting)
- ✅ Network errors (returns empty list with error logging)
- ✅ Data parsing errors (skips invalid orders)

## Complete Example

See `lib/examples/order_history_example.dart` for complete working examples with:
- StreamBuilder implementation
- FutureBuilder implementation
- Loading states
- Error states
- Empty states
- Order cards with status indicators

## Integration with Existing Code

To integrate with your existing `PurchaseHistoryScreen`:

1. Replace the current order fetching logic with:
   ```dart
   final orders = await _orderService.getUserOrders();
   ```

2. Or use StreamBuilder for real-time updates:
   ```dart
   StreamBuilder<List<Order>>(
     stream: _orderService.getUserOrdersStream(),
     ...
   )
   ```

## Notes

- Orders are automatically sorted by `createdAt` descending (newest first)
- If Firestore composite index is missing, the service falls back to manual sorting
- The service uses the in-memory cache from `FirebaseService` for user ID lookup
- All methods include comprehensive error logging for debugging

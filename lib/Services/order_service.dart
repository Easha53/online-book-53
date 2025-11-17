import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/order_model.dart'; // Changed to lowercase

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Configurable values
  final double taxRate = 0.10; // 10% tax example
  final double loyaltyPercent = 0.05; // earn 5% of subtotal as points
  final double tkPerPointsUnit = 0.2; // 1 point = 0.2 TK

  Future<int> getUserPoints(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return 0;
      return (doc.data()?['loyaltyPoints'] ?? 0).toInt();
    } catch (e) {
      return 0;
    }
  }

  Future<void> updateUserPoints(String uid, {required int addPoints, required int subtractPoints}) async {
    try {
      final ref = _db.collection('users').doc(uid);
      await _db.runTransaction((tx) async {
        final snapshot = await tx.get(ref);
        int current = 0;
        if (snapshot.exists) current = (snapshot.data()?['loyaltyPoints'] ?? 0).toInt();
        int updated = current + addPoints - subtractPoints;
        if (updated < 0) updated = 0;
        tx.set(ref, {'loyaltyPoints': updated}, SetOptions(merge: true));
      });
    } catch (e) {
      print('Error updating user points: $e');
    }
  }

  double calculateTax(double subtotal) {
    return subtotal * taxRate;
  }

  int calculateLoyaltyEarned(double subtotal) {
    return (subtotal * loyaltyPercent).round();
  }

  double loyaltyPointsToTk(int points) {
    return points * tkPerPointsUnit;
  }

  Future<void> placeOrder({
    required String name,
    required String phone,
    required String email,
    required String address,
    required String paymentMethod,
    required List<OrderItem> items,
    int usedPoints = 0,
  }) async {
    try {
      final user = _auth.currentUser;
      final uid = user?.uid;

      double subtotal = 0;
      for (var it in items) {
        subtotal += it.price * it.quantity;
      }
      final tax = calculateTax(subtotal);
      final discount = loyaltyPointsToTk(usedPoints);
      final finalAmount = (subtotal + tax) - discount;
      final earnedPoints = calculateLoyaltyEarned(subtotal);

      final orderData = {
        'customerName': name,
        'phone': phone,
        'email': email,
        'address': address,
        'paymentMethod': paymentMethod,
        'subtotal': subtotal,
        'taxAmount': tax,
        'discountAmount': discount,
        'finalAmount': finalAmount,
        'loyaltyEarned': earnedPoints,
        'loyaltyUsed': usedPoints,
        'status': 'Pending',
        'orderDate': DateTime.now().toIso8601String(),
        'userId': uid,
        'items': items.map((e) => e.toMap()).toList(),
        'paid': paymentMethod == 'Online Payment',
      };

      final orderRef = await _db.collection('orders').add(orderData);

      // update user points (if logged in)
      if (uid != null) {
        await updateUserPoints(uid, addPoints: earnedPoints, subtractPoints: usedPoints);
        // also add reference under user's orders subcollection
        await _db.collection('users').doc(uid).collection('orders').doc(orderRef.id).set({
          'orderRef': orderRef.id,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error placing order: $e');
      rethrow;
    }
  }

  // Admin functions
  Stream<List<OrderModel>> streamAllOrders() {
    return _db.collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
      try {
        return OrderModel.fromMap(d.id, d.data() as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing order: $e');
        return OrderModel(
          id: d.id,
          customerName: 'Error',
          phone: '',
          email: '',
          address: '',
          paymentMethod: 'Cash on Delivery',
          subtotal: 0,
          taxAmount: 0,
          discountAmount: 0,
          finalAmount: 0,
          loyaltyEarned: 0,
          loyaltyUsed: 0,
          status: 'Error',
          orderDate: DateTime.now(),
          userId: '',
          items: [],
          paid: false,
        );
      }
    }).toList());
  }

  // Customer functions - Get user's orders
  Stream<List<OrderModel>> streamUserOrders(String userId) {
    return _db.collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
      try {
        return OrderModel.fromMap(d.id, d.data() as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing user order: $e');
        return OrderModel(
          id: d.id,
          customerName: 'Error',
          phone: '',
          email: '',
          address: '',
          paymentMethod: 'Cash on Delivery',
          subtotal: 0,
          taxAmount: 0,
          discountAmount: 0,
          finalAmount: 0,
          loyaltyEarned: 0,
          loyaltyUsed: 0,
          status: 'Error',
          orderDate: DateTime.now(),
          userId: userId,
          items: [],
          paid: false,
        );
      }
    }).toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({'status': status});
  }

  Future<void> markPaid(String orderId, bool paid) async {
    await _db.collection('orders').doc(orderId).update({'paid': paid});
  }
}
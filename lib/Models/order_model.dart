class OrderItem {
  final String bookId;
  final String title;
  final int quantity;
  final double price;

  OrderItem({
    required this.bookId,
    required this.title,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      bookId: map['bookId'] ?? '',
      title: map['title'] ?? '',
      quantity: (map['quantity'] ?? 0).toInt(),
      price: (map['price'] ?? 0).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final String customerName;
  final String phone;
  final String email;
  final String address;
  final String paymentMethod; // "Cash on Delivery" or "Online Payment"
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double finalAmount;
  final int loyaltyEarned;
  final int loyaltyUsed;
  final String status; // Pending, Accepted, Packed, Shipped, Delivered, Cancelled
  final DateTime orderDate;
  final String? userId;
  final List<OrderItem> items;
  final bool paid;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.address,
    required this.paymentMethod,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.loyaltyEarned,
    required this.loyaltyUsed,
    required this.status,
    required this.orderDate,
    required this.userId,
    required this.items,
    required this.paid,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'phone': phone,
      'email': email,
      'address': address,
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'loyaltyEarned': loyaltyEarned,
      'loyaltyUsed': loyaltyUsed,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'userId': userId,
      'items': items.map((e) => e.toMap()).toList(),
      'paid': paid,
    };
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      customerName: map['customerName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'Cash on Delivery',
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0).toDouble(),
      finalAmount: (map['finalAmount'] ?? 0).toDouble(),
      loyaltyEarned: (map['loyaltyEarned'] ?? 0).toInt(),
      loyaltyUsed: (map['loyaltyUsed'] ?? 0).toInt(),
      status: map['status'] ?? 'Pending',
      orderDate: DateTime.parse(map['orderDate'] ?? DateTime.now().toIso8601String()),
      userId: map['userId'],
      items: (map['items'] as List<dynamic>? ?? []).map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e))).toList(),
      paid: map['paid'] ?? false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/order_model.dart'; // lowercase
import '../Services/order_service.dart'; // lowercase
import '../Customer/customer_orders_page.dart'; // Add this import

class OrderPage extends StatefulWidget {
  final List<OrderItem> cartItems;
  const OrderPage({super.key, required this.cartItems});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  String paymentMethod = 'Cash on Delivery';
  bool applyingPoints = false;
  int availablePoints = 0;
  int usePoints = 0;
  bool loadingPoints = true;
  bool placingOrder = false;

  final OrderService _service = OrderService();

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
    _prefillUser();
  }

  void _prefillUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      nameCtrl.text = user.displayName ?? '';
      emailCtrl.text = user.email ?? '';
    }
  }

  Future<void> _loadUserPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final p = await _service.getUserPoints(user.uid);
      setState(() {
        availablePoints = p;
        loadingPoints = false;
      });
    } else {
      setState(() {
        availablePoints = 0;
        loadingPoints = false;
      });
    }
  }

  double get subtotal {
    double s = 0;
    for (var it in widget.cartItems) s += it.price * it.quantity;
    return s;
  }

  double get tax => _service.calculateTax(subtotal);

  double get discount => _service.loyaltyPointsToTk(usePoints);

  double get finalAmount => (subtotal + tax) - discount;

  int get loyaltyEarned => _service.calculateLoyaltyEarned(subtotal);

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { placingOrder = true; });
    try {
      await _service.placeOrder(
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        paymentMethod: paymentMethod,
        items: widget.cartItems,
        usedPoints: usePoints,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.purple),
              SizedBox(width: 8),
              Text('Order Confirmed!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Thank you for your order!'),
              const SizedBox(height: 8),
              Text('Order Total: ৳${finalAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('Status: ${paymentMethod == 'Online Payment' ? 'Paid & Processing' : 'Pending Payment'}'),
              const SizedBox(height: 12),
              const Text(
                'You can track your order status in "My Orders" page.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Continue Shopping'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerOrdersPage(),
                  ),
                );
              },
              child: const Text('View Orders', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order failed: $e'), backgroundColor: Colors.purple),
      );
    } finally {
      if (mounted) setState(() { placingOrder = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Order'),
        backgroundColor: Colors.purple,
      ),
      backgroundColor: Colors.purple[50],
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            // Cart summary
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cart Items', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    const SizedBox(height: 8),
                    ...widget.cartItems.map((it) => ListTile(
                      dense: true,
                      title: Text(it.title, style: const TextStyle(color: Colors.purple)),
                      subtitle: Text('Qty: ${it.quantity}', style: const TextStyle(color: Colors.purple)),
                      trailing: Text('৳${(it.price * it.quantity).toStringAsFixed(2)}', style: const TextStyle(color: Colors.deepPurple)),
                    )),
                    const Divider(),
                    ListTile(title: const Text('Subtotal', style: TextStyle(color: Colors.purple)), trailing: Text('৳${subtotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.purple))),
                    ListTile(title: const Text('Tax', style: TextStyle(color: Colors.purple)), trailing: Text('৳${tax.toStringAsFixed(2)}', style: const TextStyle(color: Colors.purple))),
                    ListTile(title: const Text('Discount', style: TextStyle(color: Colors.purple)), trailing: Text('- ৳${discount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green))),
                    ListTile(
                        title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        trailing: Text('৳${finalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Full name',
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.purple)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.purple)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Enter phone' : null,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.purple)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressCtrl,
                    decoration: InputDecoration(
                      labelText: 'Delivery address',
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.purple)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Enter address' : null,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 16),

                  // Payment method
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Method',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Select:', style: TextStyle(color: Colors.purple)),
                              const SizedBox(width: 12),
                              DropdownButton<String>(
                                value: paymentMethod,
                                items: const [
                                  DropdownMenuItem(value: 'Cash on Delivery', child: Text('Cash on Delivery')),
                                  DropdownMenuItem(value: 'Online Payment', child: Text('Online Payment (mock)')),
                                ],
                                onChanged: (v) {
                                  setState(() { paymentMethod = v!; });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Loyalty Points Section
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Loyalty Points',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
                          ),
                          const SizedBox(height: 8),
                          loadingPoints
                              ? const Center(child: CircularProgressIndicator(color: Colors.purple))
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Available loyalty points: $availablePoints', style: const TextStyle(color: Colors.purple)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('Use points?', style: TextStyle(color: Colors.purple)),
                                  const SizedBox(width: 8),
                                  Switch(
                                    activeColor: Colors.purple,
                                    value: applyingPoints,
                                    onChanged: (val) {
                                      setState(() {
                                        applyingPoints = val;
                                        if (!val) usePoints = 0;
                                      });
                                    },
                                  )
                                ],
                              ),
                              if (applyingPoints) Column(
                                children: [
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: '0',
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: 'Points to use (max $availablePoints)',
                                            border: const OutlineInputBorder(),
                                            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
                                          ),
                                          onChanged: (v) {
                                            final val = int.tryParse(v) ?? 0;
                                            setState(() {
                                              usePoints = val.clamp(0, availablePoints);
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                                        onPressed: () {
                                          setState(() {
                                            usePoints = availablePoints;
                                          });
                                        },
                                        child: const Text('Use all', style: TextStyle(color: Colors.white)),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Discount: ৳${discount.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  placingOrder
                      ? const Center(child: CircularProgressIndicator(color: Colors.purple))
                      : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _placeOrder,
                      child: const Text('Place Order'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
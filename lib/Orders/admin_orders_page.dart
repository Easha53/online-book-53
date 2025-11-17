import 'package:flutter/material.dart';
import '../Models/order_model.dart';
import '../Services/order_service.dart';
import 'package:intl/intl.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final OrderService _service = OrderService();

  final statuses = ['Pending','Accepted','Packed','Shipped','Delivered','Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Orders (Admin)')),
      body: StreamBuilder<List<OrderModel>>(
        stream: _service.streamAllOrders(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snap.hasData || snap.data!.isEmpty) return const Center(child: Text('No orders yet'));
          final orders = snap.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, idx) {
              final o = orders[idx];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ExpansionTile(
                  title: Text('${o.customerName} — ${o.finalAmount.toStringAsFixed(2)} Tk'),
                  subtitle: Text('${o.status} • ${DateFormat.yMd().add_jm().format(o.orderDate)}'),
                  children: [
                    ListTile(title: const Text('Phone'), subtitle: Text(o.phone)),
                    ListTile(title: const Text('Email'), subtitle: Text(o.email)),
                    ListTile(title: const Text('Address'), subtitle: Text(o.address)),
                    ListTile(title: const Text('Payment'), subtitle: Text('${o.paymentMethod} • Paid: ${o.paid}')),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...o.items.map((it) => ListTile(
                      title: Text(it.title),
                      subtitle: Text('Qty: ${it.quantity}'),
                      trailing: Text('${(it.price * it.quantity).toStringAsFixed(2)} Tk'),
                    )),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: [
                          DropdownButton<String>(
                            value: o.status,
                            items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) async {
                              if (v == null) return;
                              await _service.updateOrderStatus(o.id, v);
                            },
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              await _service.markPaid(o.id, true);
                            },
                            child: const Text('Mark Paid'),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

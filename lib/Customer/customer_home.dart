import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/book_model.dart';
import '../Services/book_service.dart';
import '../Orders/order_page.dart';
import '../Models/order_model.dart';
import 'customer_orders_page.dart';
import '../Admin/admin_home.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final List<Book> _cart = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String userRole = "";

  final List<String> _categories = [
    'All',
    'Fiction',
    'Science',
    'Historical',
    'Comics',
    'Novel'
  ];

  void getUserRole() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    setState(() {
      userRole = snap['role'];
    });
  }

  @override
  void initState() {
    super.initState();
    getUserRole();
  }

  void addToCart(Book book) {
    setState(() => _cart.add(book));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${book.title}" added to cart'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void openCartPage() async {
    bool? cartUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          cart: _cart,
        ),
      ),
    );

    if (cartUpdated == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: const Text('Book Store'),
        backgroundColor: Colors.purple,
        centerTitle: true,
        actions: [
          if (userRole == "admin")
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminHomePage()));
              },
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: "Admin Dashboard",
              color: Colors.white,
            ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerOrdersPage()));
            },
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My Orders',
            color: Colors.white,
          ),
          Stack(
            children: [
              IconButton(
                onPressed: openCartPage,
                icon: const Icon(Icons.shopping_cart),
                color: Colors.white,
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _cart.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search, color: Colors.purple),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.purple),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),

          // Category Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Text('Category:',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.purple)),
                const SizedBox(width: 10),
                DropdownButton(
                  value: _selectedCategory,
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat,
                          style: const TextStyle(color: Colors.purple),
                        ));
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value!),
                )
              ],
            ),
          ),

          // Book List
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: BookService.getBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.purple));
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.purple)));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child:
                      Text('No books available', style: TextStyle(color: Colors.purple)));
                }

                final filteredBooks = snapshot.data!.where((book) {
                  final matchSearch =
                      book.title.toLowerCase().contains(_searchQuery) ||
                          book.author.toLowerCase().contains(_searchQuery);
                  final matchCat = _selectedCategory == 'All' ||
                      book.category == _selectedCategory;
                  return matchSearch && matchCat;
                }).toList();

                if (filteredBooks.isEmpty) {
                  return const Center(
                      child:
                      Text('No books found', style: TextStyle(color: Colors.purple)));
                }

                return ListView.builder(
                  itemCount: filteredBooks.length,
                  itemBuilder: (_, i) {
                    final b = filteredBooks[i];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.title,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple)),
                            Text("Author: ${b.author}",
                                style: const TextStyle(color: Colors.purple)),
                            Text("Category: ${b.category}",
                                style: const TextStyle(color: Colors.purple)),
                            const SizedBox(height: 8),
                            Text(
                              b.description.length > 100
                                  ? '${b.description.substring(0, 100)}...'
                                  : b.description,
                              style: const TextStyle(color: Colors.purple),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '৳ ${b.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                        foregroundColor: Colors.white,
                                      ),
                                      icon: const Icon(Icons.add_shopping_cart,
                                          size: 16),
                                      label: const Text("Add to Cart"),
                                      onPressed: () => addToCart(b),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        List<OrderItem> orderItems = [
                                          OrderItem(
                                            bookId: b.id,
                                            title: b.title,
                                            quantity: 1,
                                            price: b.price,
                                          )
                                        ];

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                OrderPage(cartItems: orderItems),
                                          ),
                                        );
                                      },
                                      child: const Text("Buy Now"),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- CART PAGE ------------------

class CartPage extends StatefulWidget {
  final List<Book> cart;

  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double get totalPrice {
    double total = 0;
    for (var book in widget.cart) {
      total += book.price;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar:
      AppBar(title: const Text("My Cart"), backgroundColor: Colors.purple),
      body: widget.cart.isEmpty
          ? const Center(
        child:
        Text("Your cart is empty", style: TextStyle(color: Colors.purple)),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cart.length,
              itemBuilder: (_, i) {
                final book = widget.cart[i];
                return ListTile(
                  leading: const Icon(Icons.book, color: Colors.purple),
                  title:
                  Text(book.title, style: const TextStyle(color: Colors.deepPurple)),
                  subtitle:
                  Text("৳ ${book.price.toStringAsFixed(2)}", style: const TextStyle(color: Colors.purple)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        widget.cart.removeAt(i);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[100],
              border: Border(
                  top: BorderSide(color: Colors.purple.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ৳${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 50)),
                  onPressed: () async {
                    List<OrderItem> orderItems = widget.cart
                        .map((book) => OrderItem(
                        bookId: book.id,
                        title: book.title,
                        quantity: 1,
                        price: book.price))
                        .toList();

                    bool? orderPlaced = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderPage(cartItems: orderItems),
                      ),
                    );

                    if (orderPlaced == true) {
                      setState(() {
                        widget.cart.clear();
                      });

                      Navigator.pop(context, true);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Order placed successfully! Cart cleared."),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text("Checkout"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

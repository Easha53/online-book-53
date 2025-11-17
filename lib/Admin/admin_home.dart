import 'package:flutter/material.dart';
import '../Models/book_model.dart';
import '../Services/book_service.dart';
import 'add_book_page.dart';
import '../Customer/customer_home.dart';
import '../Orders/admin_orders_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.purple,
        actions: [
          // Go to Customer Page
          IconButton(
            icon: const Icon(Icons.store, color: Colors.purpleAccent),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerHomePage()));
            },
          ),

          // Go to Orders Page
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.deepPurpleAccent),
            tooltip: "Manage Orders",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrdersPage()));
            },
          ),

          // Add Book Page
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBookPage()));
            },
          ),
        ],
      ),
      backgroundColor: Colors.purple[50],
      body: StreamBuilder<List<Book>>(
        stream: BookService.getBooks(),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.purple));
          final books = snap.data!;
          if (books.isEmpty) return const Center(child: Text("No books available", style: TextStyle(color: Colors.purple)));

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (_, i) {
              final book = books[i];
              return Card(
                margin: const EdgeInsets.all(8),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.menu_book, color: Colors.deepPurple),
                  title: Text(
                    book.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  subtitle: Text(
                    'Author: ${book.author}\nCategory: ${book.category}\nPrice: ৳${book.price}',
                    style: const TextStyle(color: Colors.purple),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.purple),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AddBookPage(book: book)));
                        },
                      ),
                      // Delete
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await BookService.deleteBook(book.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Book deleted successfully!'),
                              backgroundColor: Colors.purple,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../Models/book_model.dart';
import '../Services/book_service.dart';
import 'add_book_page.dart';
import '../Customer/customer_home.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [

          IconButton(
            icon: const Icon(Icons.store, color: Colors.redAccent),
            tooltip: 'Go to Customer Page',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CustomerHomePage()),
              );
            },
          ),
          //
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Book',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddBookPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Book>>(
        stream: BookService.getBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books available.'));
          }

          final books = snapshot.data!;
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];

              return Card(
                margin: const EdgeInsets.all(8),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.menu_book, color: Colors.deepPurple),
                  title: Text(
                    book.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Author: ${book.author}\nCategory: ${book.category}\nPrice: ৳${book.price}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔹 Edit Book
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddBookPage(book: book)),
                          );
                        },
                      ),
                      // 🔹 Delete Book
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await BookService.deleteBook(book.id);
                          messenger.showSnackBar(
                            const SnackBar(
                                content: Text('Book deleted successfully!')),
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

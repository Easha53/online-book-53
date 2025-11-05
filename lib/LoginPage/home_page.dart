// import 'package:flutter/material.dart';
// import '../Models/book_model.dart';
// import '../Services/book_service.dart';
//
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Book Store'),
//         centerTitle: true,
//       ),
//       body: StreamBuilder<List<Book>>(
//         stream: BookService.getBooks(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No books available.'));
//           }
//
//           final books = snapshot.data!;
//           return ListView.builder(
//             itemCount: books.length,
//             itemBuilder: (context, index) {
//               final book = books[index];
//               return Card(
//                 margin: const EdgeInsets.all(10),
//                 elevation: 4,
//                 child: ListTile(
//                   leading: const Icon(Icons.book, color: Colors.blue),
//                   title: Text(
//                     book.title,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(
//                     'Author: ${book.author}\nCategory: ${book.category}',
//                     style: const TextStyle(fontSize: 13),
//                   ),
//                   trailing: Text(
//                     '৳ ${book.price.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                         color: Colors.green, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

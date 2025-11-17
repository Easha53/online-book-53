import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/book_model.dart';

class BookService {
  static final CollectionReference booksCollection =
  FirebaseFirestore.instance.collection('books');

  static Future<void> addBook(Book book) async {
    await booksCollection.add(book.toMap());
  }

  static Future<void> updateBook(Book book) async {
    await booksCollection.doc(book.id).update(book.toMap());
  }

  static Future<void> deleteBook(String id) async {
    await booksCollection.doc(id).delete();
  }

  static Stream<List<Book>> getBooks() {
    return booksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Book.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
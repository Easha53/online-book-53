import 'package:flutter/material.dart';
import '../Models/book_model.dart';
import '../Services/book_service.dart';

class AddBookPage extends StatefulWidget {
  final Book? book;

  const AddBookPage({super.key, this.book});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _categoryController;
  late TextEditingController _descController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _authorController = TextEditingController(text: widget.book?.author ?? '');
    _categoryController =
        TextEditingController(text: widget.book?.category ?? '');
    _descController =
        TextEditingController(text: widget.book?.description ?? '');
    _priceController =
        TextEditingController(text: widget.book?.price.toString() ?? '');
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    final book = Book(
      id: widget.book?.id ?? '',
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      category: _categoryController.text.trim(),
      description: _descController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
    );

    if (widget.book == null) {
      await BookService.addBook(book);
    } else {
      await BookService.updateBook(book);
    }


    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            widget.book == null ? 'Book added successfully!' : 'Book updated successfully!'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.book == null ? 'Add New Book' : 'Edit Book')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter book title' : null,
                ),
                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(labelText: 'Author'),
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Text(widget.book == null ? 'Add Book' : 'Update Book'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBookmarkSheet extends StatefulWidget {
  final String classId;

  const AddBookmarkSheet({super.key, required this.classId});

  @override
  State<AddBookmarkSheet> createState() => _AddBookmarkSheetState();
}

class _AddBookmarkSheetState extends State<AddBookmarkSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  final Color primaryColor = const Color(0xFF5A67D8);

  Future<void> _saveBookmark() async {
    if (_titleController.text.isEmpty || _urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title and URL are required!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('bookmarks').add({
        'class_id': widget.classId,
        'title': _titleController.text.trim(),
        'url': _urlController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bookmark Saved! 🔖"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 24),
          
          Text("Add Bookmark", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primaryColor)),
          const SizedBox(height: 24),

          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: "Title (e.g., Syllabus, Playlist)",
              filled: true, fillColor: Colors.grey[50],
              prefixIcon: Icon(Icons.bookmark_border_rounded, color: primaryColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: "Paste link here (https://...)",
              filled: true, fillColor: Colors.grey[50],
              prefixIcon: Icon(Icons.link_rounded, color: primaryColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              onPressed: _isLoading ? null : _saveBookmark,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Bookmark", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
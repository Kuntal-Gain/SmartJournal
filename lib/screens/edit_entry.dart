// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../services/journal_entry_adapter.dart';
import '../services/journal_services.dart';
import '../utils/custom_snackbar.dart';

class EditEntryScreen extends StatefulWidget {
  final JournalEntry entry;
  const EditEntryScreen({super.key, required this.entry});

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  void saveEntry() async {
    JournalEntry entry = JournalEntry(
      entryId: widget.entry.entryId,
      title: _titleController.text.isEmpty ? "No Title" : _titleController.text,
      content:
          _bodyController.text.isEmpty ? "No Content" : _bodyController.text,
      color: widget.entry.color,
      createdAt: DateTime.now(),
    );

    await JournalServices().saveJournal(entry).then((_) {
      successBar(context, "Entry Saved");
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _bodyController = TextEditingController(text: widget.entry.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(widget.entry.color),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => saveEntry(),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0XFF5D3D3D),
            )),
        backgroundColor: Color(widget.entry.color),
        title: const Text(
          "Edit Entry",
          style:
              TextStyle(color: Color(0XFF5D3D3D), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Transform.rotate(
              angle: 45 * 3.14159 / 180, // Convert 45 degrees to radians
              child: const Icon(
                Icons.attach_file,
                color: Color(0XFF5D3D3D),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter Title',
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0XFF5D3D3D),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DateTime.now().toString().split(' ')[0],
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Write your thoughts...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

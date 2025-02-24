// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:personal_dairy/services/embedding_services.dart';
import 'package:personal_dairy/services/journal_services.dart';
import 'package:personal_dairy/utils/custom_snackbar.dart';

import '../services/journal_entry_adapter.dart';

class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({super.key});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  final List<Color> colors = [
    Colors.red.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.purple.shade100,
    Colors.orange.shade100,
    Colors.yellow.shade100,
    Colors.pink.shade100,
    Colors.teal.shade100,
    Colors.indigo.shade100,
  ];

  String generateId() => 'J${Random().nextInt(100)}';
  Color getColor() => colors[Random().nextInt(colors.length)];

  void saveEntry() async {
    final id = generateId();

    JournalEntry entry = JournalEntry(
      entryId: id,
      title: _titleController.text.isEmpty ? "No Title" : _titleController.text,
      content:
          _bodyController.text.isEmpty ? "No Content" : _bodyController.text,
      color: getColor().value,
      createdAt: DateTime.now(),
    );

    await JournalServices().saveJournal(entry).then((_) {
      successBar(context, "Entry Saved");
      Navigator.pop(context);
    });

    EmbeddingServices().storeInPinecone(id, _bodyController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => saveEntry(),
            icon: Icon(
              Icons.arrow_back,
              color: Color(0XFF5D3D3D),
            )),
        backgroundColor: Colors.white,
        title: Text(
          "New Entry",
          style:
              TextStyle(color: Color(0XFF5D3D3D), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Transform.rotate(
              angle: 45 * 3.14159 / 180, // Convert 45 degrees to radians
              child: Icon(
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
              decoration: InputDecoration(
                hintText: 'Enter Title',
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0XFF5D3D3D),
              ),
            ),
            SizedBox(height: 16),
            Text(
              DateTime.now().toString().split(' ')[0],
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                decoration: InputDecoration(
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

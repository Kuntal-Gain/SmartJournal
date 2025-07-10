import 'package:flutter/material.dart';
import '../services/journal_entry_adapter.dart';
import 'edit_entry.dart';
import 'widgets/markdown_preview.dart';

class ViewEntryScreen extends StatefulWidget {
  final JournalEntry entry;
  const ViewEntryScreen({super.key, required this.entry});

  @override
  State<ViewEntryScreen> createState() => _ViewEntryScreenState();
}

class _ViewEntryScreenState extends State<ViewEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _bodyController = TextEditingController(text: widget.entry.content);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(widget.entry.color),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0XFF5D3D3D),
            )),
        backgroundColor: Color(widget.entry.color),
        title: const Text(
          "View Entry",
          style:
              TextStyle(color: Color(0XFF5D3D3D), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEntryScreen(entry: widget.entry),
                ),
              );
            },
            icon: const Icon(
              Icons.edit,
              color: Color(0XFF5D3D3D),
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
              child: Column(
                children: [
                  Expanded(child: MarkdownPreview(_bodyController.text)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

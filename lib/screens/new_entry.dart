import 'package:flutter/material.dart';

class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({super.key});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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

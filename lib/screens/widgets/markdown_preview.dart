import 'package:flutter/material.dart';

class MarkdownPreview extends StatelessWidget {
  final String text;

  const MarkdownPreview(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final lines = text.split('\n');

    return ListView.builder(
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final line = lines[index];

        // 1. Image: [image](url)
        final imageRegex = RegExp(r'\[image\]\((.*?)\)', caseSensitive: false);
        final imageMatch = imageRegex.firstMatch(line);
        if (imageMatch != null) {
          final imageUrl = imageMatch.group(1);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.contain,
                height: mq.height * 0.18,
                width: mq.width * 0.8,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Text('⚠️ Failed to load image'),
              ),
            ),
          );
        }

        // h1
        else if (line.startsWith('# ')) {
          return Text(
            line.substring(2),
            style: const TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          );
        }

        // h2
        else if (line.startsWith('## ')) {
          return Text(
            line.substring(3),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          );
        }

        // h3
        else if (line.startsWith('### ')) {
          return Text(
            line.substring(4),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          );
        }

        // Notice block
        else if (line.startsWith('> ')) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                left: BorderSide(
                  color: Colors.red,
                  width: 4,
                ),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              line.substring(2),
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.amber,
              ),
            ),
          );
        }

        // Default text
        else {
          return Text(
            line,
            style: const TextStyle(fontSize: 16),
          );
        }
      },
    );
  }
}

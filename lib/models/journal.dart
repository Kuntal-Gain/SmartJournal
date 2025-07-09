import 'dart:ui';

class Journal {
  String entryId;
  String title;
  String content;

  String createdAt;

  Journal({
    required this.entryId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory Journal.fromJson(Map<String, dynamic> json) {
    final dat = json['metadata'];

    return Journal(
      entryId: (dat['entryId'] ?? json['id']) as String,
      title: dat['title'] as String? ?? '',
      content: dat['content'] as String? ?? '',
      createdAt: dat['createdAt'] as String? ?? '',
    );
  }
}

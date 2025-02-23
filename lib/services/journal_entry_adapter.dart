import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'journal_entry_adapter.g.dart';

@HiveType(typeId: 0)
class JournalEntry extends HiveObject {
  @HiveField(0)
  String entryId;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  String content;

  @HiveField(4)
  int color;

  Color get entryColor => Color(color); // Convert int back to Color

  JournalEntry({
    required this.entryId,
    required this.title,
    required this.createdAt,
    required this.content,
    required this.color,
  });
}

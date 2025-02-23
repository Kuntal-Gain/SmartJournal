import 'package:hive/hive.dart';
import 'package:personal_dairy/services/journal_entry_adapter.dart';
import 'dart:async';

class JournalServices {
  static final JournalServices _instance = JournalServices._internal();
  factory JournalServices() => _instance;
  JournalServices._internal();

  final key = "journal_entries";
  final _journalController = StreamController<List<JournalEntry>>.broadcast();
  Stream<List<JournalEntry>> get journalStream => _journalController.stream;

  Future<void> saveJournal(JournalEntry journal) async {
    final box = Hive.box<JournalEntry>(key);

    await box.put(journal.entryId, journal);

    print("Entry saved");

    // After saving, emit the updated list
    final updatedEntries = fetchAllEntries();
    _journalController.add(updatedEntries);
  }

  List<JournalEntry> fetchAllEntries() {
    final box = Hive.box<JournalEntry>(key);

    return box.values.toList();
  }

  JournalEntry? getJournalById(String id) {
    final box = Hive.box<JournalEntry>(key);

    return box.get(id);
  }
}

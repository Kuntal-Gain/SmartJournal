import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:personal_dairy/services/journal_entry_adapter.dart';
import 'package:personal_dairy/services/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal.dart';

class EmbeddingServices {
  Future<List<double>> getEmbeddings(String text) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/text-embedding-004:embedContent?key=$apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "models/text-embedding-004",
        "content": {
          "parts": [
            {"text": text}
          ]
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<double>.from(data["embedding"]["values"]);
    } else {
      throw Exception('Failed to load embeddings');
    }
  }

  Future<String> getNamespace() async =>
      await LocalStorageService(await SharedPreferences.getInstance())
          .getOrCreateNamespace();
  Future<void> storeInPinecone(String id, JournalEntry entry) async {
    final pineconeApiKey = dotenv.env['PINECONE_API_KEY'];
    final pineconeIndexUrl =
        '${dotenv.env['PINECONE_ENDPOINT']}/vectors/upsert';

    List<double> vector = await getEmbeddings(entry.content);
    final namespace = await getNamespace();

    final response = await http.post(
      Uri.parse(pineconeIndexUrl),
      headers: {
        "Content-Type": "application/json",
        "Api-Key": pineconeApiKey!,
      },
      body: jsonEncode({
        "namespace": namespace,
        "vectors": [
          {
            "id": id,
            "values": vector,
            "metadata": {
              "entryId": entry.entryId,
              "title": entry.title,
              "content": entry.content,
              "createdAt": entry.createdAt.toString(),
            }
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        if (kDebugMode) {
          print("Stored in Pinecone successfully!");
        }
      }
    } else {
      throw Exception("Failed to store in Pinecone");
    }
  }

  Future<Journal?> searchJournal(String query) async {
    final pineconeApiKey = dotenv.env['PINECONE_API_KEY'];
    final pineconeIndexUrl = '${dotenv.env['PINECONE_ENDPOINT']}/query';
    final namespace = await getNamespace();

    debugPrint('[Pinecone] namespace → $namespace');

    // 🔎 Embed the query once
    final List<double> queryVector = await getEmbeddings(query);

    final response = await http.post(
      Uri.parse(pineconeIndexUrl),
      headers: {
        'Content-Type': 'application/json',
        'Api-Key': pineconeApiKey!,
      },
      body: jsonEncode({
        'namespace': namespace,
        'vector': queryVector,
        'topK': 1, // most relevant hit
        'includeMetadata': true,
      }),
    );

    // ──────────────────────────────────────────────────────────────────────
    //                  RESPONSE HANDLING & DECODING
    // ──────────────────────────────────────────────────────────────────────
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to search Pinecone (HTTP ${response.statusCode})');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    data.forEach((key, value) {
      debugPrint('[Pinecone] $key : ${value.runtimeType} → $value');
    });

    final List<dynamic> matches = data['matches'] as List<dynamic>? ?? [];

    if (matches.isEmpty) {
      return null; // caller decides what “no match” looks like
    }

    // `Journal.fromJson` understands both flat & metadata‑nested blobs
    final Journal journal =
        Journal.fromJson(matches.first as Map<String, dynamic>);

    if (kDebugMode) {
      debugPrint('[Pinecone] ${journal.title} → ${journal.content}');
    }

    return journal;
  }

  Future<String> generateGeminiResponse(String lastMemory, String query) async {
    debugPrint('[Gemini] lastMemory → $lastMemory');
    debugPrint('[Gemini] query → $query');

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'X-goog-api-key': apiKey!},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Given the following previous context about the user's work:\n\n---\n[Previous Memory/Context about Socialseed]:\n$lastMemory\n---\n\nNow, respond to the current query, ensuring your answer is consistent with the provided previous memory and refers to the user as 'you':\n\n[Current Query]:\n$query"
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      throw Exception('Failed to generate response');
    }
  }

  Future<String> generateFollowup(String prevResponse, String newQuery) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Given the current query: $newQuery, respond based on the previous response: $prevResponse, ensuring consistency with past responses."
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else {
      throw Exception('Failed to generate response');
    }
  }
}

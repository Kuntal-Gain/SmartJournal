import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  Future<void> storeInPinecone(String id, String text) async {
    final pineconeApiKey = dotenv.env['PINECONE_API_KEY'];
    final pineconeIndexUrl =
        '${dotenv.env['PINECONE_ENDPOINT']}/vectors/upsert';

    List<double> vector = await getEmbeddings(text);

    final response = await http.post(
      Uri.parse(pineconeIndexUrl),
      headers: {
        "Content-Type": "application/json",
        "Api-Key": pineconeApiKey!,
      },
      body: jsonEncode({
        "vectors": [
          {
            "id": id,
            "values": vector,
            "metadata": {"text": text}
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      print("Stored in Pinecone successfully!");
    } else {
      throw Exception("Failed to store in Pinecone");
    }
  }

  Future<String> searchJournal(String query) async {
    final pineconeApiKey = dotenv.env['PINECONE_API_KEY'];
    final pineconeIndexUrl = '${dotenv.env['PINECONE_ENDPOINT']}/query';

    List<double> queryVector = await getEmbeddings(query);

    final response = await http.post(
      Uri.parse(pineconeIndexUrl!),
      headers: {
        "Content-Type": "application/json",
        "Api-Key": pineconeApiKey!,
      },
      body: jsonEncode({
        "vector": queryVector,
        "topK": 1, // Get the most relevant journal entry
        "includeMetadata": true
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["matches"].isNotEmpty) {
        print(data["matches"][0]["metadata"]["text"]);
        return data["matches"][0]["metadata"]["text"];
      } else {
        return "No matching journal entry found.";
      }
    } else {
      throw Exception("Failed to search Pinecone");
    }
  }

  Future<String> generateGeminiResponse(String lastMemory, String query) async {
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
                    "Given the current query: $query, respond based on the previous memory: $lastMemory, ensuring consistency with past responses."
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

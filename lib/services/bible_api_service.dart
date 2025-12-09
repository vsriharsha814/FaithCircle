import 'dart:convert';
import 'package:http/http.dart' as http;

class BibleVerse {
  final String reference;
  final String text;
  final String? translation;

  BibleVerse({
    required this.reference,
    required this.text,
    this.translation,
  });
}

abstract class BibleApiService {
  Future<List<BibleVerse>> searchVerses(String query);
  Future<BibleVerse?> getVerse(String reference, {String? translation});
}

// Implementation using bible-api.com (free, no API key needed)
class BibleApiComService implements BibleApiService {
  static const String baseUrl = 'https://bible-api.com';
  
  // Available translations: kjv, asv, web, bbe, ylt
  final String defaultTranslation = 'kjv';

  @override
  Future<List<BibleVerse>> searchVerses(String query) async {
    // Note: bible-api.com doesn't have a search endpoint
    // This would need to be implemented differently or use a different approach
    // For now, we'll return an empty list and handle search differently
    return [];
  }

  @override
  Future<BibleVerse?> getVerse(String reference, {String? translation}) async {
    try {
      final translationParam = translation ?? defaultTranslation;
      final url = Uri.parse('$baseUrl/$reference?translation=$translationParam');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BibleVerse(
          reference: data['reference'] ?? reference,
          text: data['text'] ?? '',
          translation: translationParam,
        );
      }
      return null;
    } catch (e) {
      // Only log non-network errors to avoid console spam
      final errorMsg = e.toString().toLowerCase();
      if (!errorMsg.contains('socketexception') && 
          !errorMsg.contains('failed host lookup')) {
        print('Error fetching verse: $e');
      }
      return null;
    }
  }

  // Helper method to get multiple verses (for search functionality)
  Future<List<BibleVerse>> getVersesByQuery(String query) async {
    // Since bible-api.com doesn't have search, we can try common verse references
    // or implement a local search on a predefined list
    final commonReferences = [
      'John 3:16',
      'Philippians 4:13',
      'Jeremiah 29:11',
      'Romans 8:28',
      'Proverbs 3:5-6',
      'Isaiah 41:10',
      'Matthew 28:20',
      'Joshua 1:9',
      '1 Corinthians 13:4-5',
      'Psalm 23:1',
    ];

    final results = <BibleVerse>[];
    final queryLower = query.toLowerCase();

    for (final ref in commonReferences) {
      if (ref.toLowerCase().contains(queryLower)) {
        final verse = await getVerse(ref);
        if (verse != null) {
          results.add(verse);
        }
      }
    }

    return results;
  }
}

// Implementation using API.Bible (requires API key)
class ApiBibleService implements BibleApiService {
  final String apiKey;
  static const String baseUrl = 'https://api.scripture.api.bible/v1';

  ApiBibleService({required this.apiKey});

  @override
  Future<List<BibleVerse>> searchVerses(String query) async {
    try {
      // Get available Bibles first
      final biblesUrl = Uri.parse('$baseUrl/bibles');
      final biblesResponse = await http.get(
        biblesUrl,
        headers: {'api-key': apiKey},
      );

      if (biblesResponse.statusCode != 200) {
        return [];
      }

      final biblesData = json.decode(biblesResponse.body);
      final bibles = biblesData['data'] as List?;
      if (bibles == null || bibles.isEmpty) {
        return [];
      }

      // Use first available Bible for search
      final bibleId = bibles[0]['id'] as String;
      final searchUrl = Uri.parse('$baseUrl/bibles/$bibleId/search')
          .replace(queryParameters: {'query': query});

      final searchResponse = await http.get(
        searchUrl,
        headers: {'api-key': apiKey},
      );

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final passages = searchData['data']?['passages'] as List?;
        
        if (passages != null) {
          return passages.map((passage) {
            return BibleVerse(
              reference: passage['reference'] ?? '',
              text: passage['content'] ?? '',
            );
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error searching verses: $e');
      return [];
    }
  }

  @override
  Future<BibleVerse?> getVerse(String reference, {String? translation}) async {
    try {
      // Get available Bibles
      final biblesUrl = Uri.parse('$baseUrl/bibles');
      final biblesResponse = await http.get(
        biblesUrl,
        headers: {'api-key': apiKey},
      );

      if (biblesResponse.statusCode != 200) {
        return null;
      }

      final biblesData = json.decode(biblesResponse.body);
      final bibles = biblesData['data'] as List?;
      if (bibles == null || bibles.isEmpty) {
        return null;
      }

      // Find Bible by abbreviation or use first one
      String? bibleId;
      if (translation != null) {
        for (final bible in bibles) {
          if (bible['abbreviation']?.toString().toLowerCase() == 
              translation.toLowerCase()) {
            bibleId = bible['id'] as String;
            break;
          }
        }
      }
      bibleId ??= bibles[0]['id'] as String;

      // Parse reference (e.g., "John 3:16" -> "JHN.3.16")
      final parsedRef = _parseReference(reference);
      final verseUrl = Uri.parse('$baseUrl/bibles/$bibleId/passages/$parsedRef');

      final response = await http.get(
        verseUrl,
        headers: {'api-key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BibleVerse(
          reference: data['data']?['reference'] ?? reference,
          text: data['data']?['content'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Error fetching verse: $e');
      return null;
    }
  }

  String _parseReference(String reference) {
    // Convert "John 3:16" to "JHN.3.16" format
    // This is a simplified parser - you'd need a more robust one
    final parts = reference.split(' ');
    if (parts.length >= 2) {
      final book = parts[0];
      final chapterVerse = parts[1];
      final cvParts = chapterVerse.split(':');
      if (cvParts.length == 2) {
        return '${book.toUpperCase()}.${cvParts[0]}.${cvParts[1]}';
      }
    }
    return reference;
  }
}

// Factory to easily switch between implementations
class BibleServiceFactory {
  static BibleApiService createService({
    String? apiKey,
    bool useApiBible = false,
  }) {
    if (useApiBible && apiKey != null && apiKey.isNotEmpty) {
      return ApiBibleService(apiKey: apiKey);
    }
    return BibleApiComService();
  }
}


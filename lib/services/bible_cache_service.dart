import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'bible_api_service.dart';

class BibleCacheService {
  static const String _cacheKey = 'bible_verse_cache';
  static const String _cacheTimestampKey = 'bible_cache_timestamp';
  static const int _maxCacheSize = 1000; // Max cached verses
  static const Duration _cacheExpiry = Duration(days: 30);

  // Cache a verse locally
  Future<void> cacheVerse(BibleVerse verse) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_cacheKey);
      Map<String, dynamic> cache = {};
      
      if (cacheJson != null) {
        cache = json.decode(cacheJson) as Map<String, dynamic>;
      }

      // Use reference as key
      final key = verse.reference.toLowerCase().trim();
      cache[key] = {
        'reference': verse.reference,
        'text': verse.text,
        'translation': verse.translation,
        'cachedAt': DateTime.now().toIso8601String(),
      };

      // Limit cache size - remove oldest entries if needed
      if (cache.length > _maxCacheSize) {
        final entries = cache.entries.toList();
        entries.sort((a, b) {
          final aTime = DateTime.parse(a.value['cachedAt'] as String);
          final bTime = DateTime.parse(b.value['cachedAt'] as String);
          return aTime.compareTo(bTime);
        });
        
        // Remove oldest 10% of entries
        final toRemove = (_maxCacheSize * 0.1).round();
        for (int i = 0; i < toRemove && i < entries.length; i++) {
          cache.remove(entries[i].key);
        }
      }

      await prefs.setString(_cacheKey, json.encode(cache));
      await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching verse: $e');
    }
  }

  // Get a verse from cache
  Future<BibleVerse?> getCachedVerse(String reference) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_cacheKey);
      
      if (cacheJson == null) return null;

      final cache = json.decode(cacheJson) as Map<String, dynamic>;
      final key = reference.toLowerCase().trim();
      final cached = cache[key] as Map<String, dynamic>?;

      if (cached == null) return null;

      // Check if cache is expired
      final cachedAt = DateTime.parse(cached['cachedAt'] as String);
      if (DateTime.now().difference(cachedAt) > _cacheExpiry) {
        // Remove expired entry
        cache.remove(key);
        await prefs.setString(_cacheKey, json.encode(cache));
        return null;
      }

      return BibleVerse(
        reference: cached['reference'] as String,
        text: cached['text'] as String,
        translation: cached['translation'] as String?,
      );
    } catch (e) {
      print('Error getting cached verse: $e');
      return null;
    }
  }

  // Search cached verses (simple text search)
  Future<List<BibleVerse>> searchCachedVerses(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_cacheKey);
      
      if (cacheJson == null) return [];

      final cache = json.decode(cacheJson) as Map<String, dynamic>;
      final queryLower = query.toLowerCase();
      final results = <BibleVerse>[];

      for (final entry in cache.entries) {
        final cached = entry.value as Map<String, dynamic>;
        final reference = (cached['reference'] as String).toLowerCase();
        final text = (cached['text'] as String).toLowerCase();

        if (reference.contains(queryLower) || text.contains(queryLower)) {
          results.add(BibleVerse(
            reference: cached['reference'] as String,
            text: cached['text'] as String,
            translation: cached['translation'] as String?,
          ));
        }
      }

      return results;
    } catch (e) {
      print('Error searching cached verses: $e');
      return [];
    }
  }

  // Clear all cached verses
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_cacheKey);
      
      if (cacheJson == null) {
        return {'count': 0, 'size': 0};
      }

      final cache = json.decode(cacheJson) as Map<String, dynamic>;
      return {
        'count': cache.length,
        'size': cacheJson.length, // Approximate size in bytes
      };
    } catch (e) {
      return {'count': 0, 'size': 0};
    }
  }
}

// Enhanced Bible API Service with caching
class CachedBibleApiService {
  final BibleApiService _apiService;
  final BibleCacheService _cacheService;

  CachedBibleApiService(this._apiService) : _cacheService = BibleCacheService();

  Future<BibleVerse?> getVerse(String reference, {String? translation}) async {
    // Try cache first
    final cached = await _cacheService.getCachedVerse(reference);
    if (cached != null) {
      return cached;
    }

    // If not in cache, fetch from API
    try {
      final verse = await _apiService.getVerse(reference, translation: translation);
      if (verse != null) {
        // Cache it for future use
        await _cacheService.cacheVerse(verse);
      }
      return verse;
    } catch (e) {
      print('Error fetching verse from API: $e');
      return null;
    }
  }

  Future<List<BibleVerse>> searchVerses(String query) async {
    // Try cache first
    final cachedResults = await _cacheService.searchCachedVerses(query);
    
    // Also search API for more results
    try {
      List<BibleVerse> apiResults;
      
      // Handle BibleApiComService which has a special search method
      if (_apiService is BibleApiComService) {
        final service = _apiService as BibleApiComService;
        apiResults = await service.getVersesByQuery(query);
      } else {
        apiResults = await _apiService.searchVerses(query);
      }
      
      // Combine and deduplicate
      final allResults = <String, BibleVerse>{};
      
      for (final verse in cachedResults) {
        allResults[verse.reference.toLowerCase()] = verse;
      }
      
      for (final verse in apiResults) {
        final key = verse.reference.toLowerCase();
        if (!allResults.containsKey(key)) {
          allResults[key] = verse;
          // Cache new results
          await _cacheService.cacheVerse(verse);
        }
      }
      
      return allResults.values.toList();
    } catch (e) {
      // If API fails, return cached results
      return cachedResults;
    }
  }
}


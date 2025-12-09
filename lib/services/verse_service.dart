import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/verse.dart';

class VerseService {
  static const String _versesKey = 'saved_verses';

  Future<List<Verse>> getVerses() async {
    final prefs = await SharedPreferences.getInstance();
    final versesJson = prefs.getString(_versesKey);
    if (versesJson == null) return [];

    final List<dynamic> versesList = json.decode(versesJson);
    return versesList.map((json) => Verse.fromJson(json)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> saveVerse(Verse verse) async {
    final verses = await getVerses();
    final existingIndex = verses.indexWhere((v) => v.id == verse.id);
    
    if (existingIndex >= 0) {
      verses[existingIndex] = verse;
    } else {
      verses.add(verse);
    }

    final prefs = await SharedPreferences.getInstance();
    final versesJson = json.encode(verses.map((v) => v.toJson()).toList());
    await prefs.setString(_versesKey, versesJson);
  }

  Future<void> deleteVerse(String id) async {
    final verses = await getVerses();
    verses.removeWhere((v) => v.id == id);

    final prefs = await SharedPreferences.getInstance();
    final versesJson = json.encode(verses.map((v) => v.toJson()).toList());
    await prefs.setString(_versesKey, versesJson);
  }
}


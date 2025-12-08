import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/personal_note.dart';
import '../models/sermon_note.dart';

class NotesService {
  static const String _personalNotesKey = 'personal_notes';
  static const String _sermonNotesKey = 'sermon_notes';

  // Personal Notes
  Future<List<PersonalNote>> getPersonalNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString(_personalNotesKey);
    if (notesJson == null) return [];

    final List<dynamic> notesList = json.decode(notesJson);
    return notesList.map((json) => PersonalNote.fromJson(json)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> savePersonalNote(PersonalNote note) async {
    final notes = await getPersonalNotes();
    final existingIndex = notes.indexWhere((n) => n.id == note.id);
    
    if (existingIndex >= 0) {
      notes[existingIndex] = note;
    } else {
      notes.add(note);
    }

    final prefs = await SharedPreferences.getInstance();
    final notesJson = json.encode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(_personalNotesKey, notesJson);
  }

  Future<void> deletePersonalNote(String id) async {
    final notes = await getPersonalNotes();
    notes.removeWhere((n) => n.id == id);

    final prefs = await SharedPreferences.getInstance();
    final notesJson = json.encode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(_personalNotesKey, notesJson);
  }

  // Sermon Notes
  Future<List<SermonNote>> getSermonNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString(_sermonNotesKey);
    if (notesJson == null) return [];

    final List<dynamic> notesList = json.decode(notesJson);
    return notesList.map((json) => SermonNote.fromJson(json)).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> saveSermonNote(SermonNote note) async {
    final notes = await getSermonNotes();
    final existingIndex = notes.indexWhere((n) => n.id == note.id);
    
    if (existingIndex >= 0) {
      notes[existingIndex] = note;
    } else {
      notes.add(note);
    }

    final prefs = await SharedPreferences.getInstance();
    final notesJson = json.encode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(_sermonNotesKey, notesJson);
  }

  Future<void> deleteSermonNote(String id) async {
    final notes = await getSermonNotes();
    notes.removeWhere((n) => n.id == id);

    final prefs = await SharedPreferences.getInstance();
    final notesJson = json.encode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(_sermonNotesKey, notesJson);
  }
}


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/verse.dart';
import '../services/verse_service.dart';
import '../services/bible_api_service.dart';
import '../services/bible_cache_service.dart';
import '../data/bible_structure.dart';

class AddVerseScreen extends StatefulWidget {
  final Verse? verse;

  const AddVerseScreen({super.key, this.verse});

  @override
  State<AddVerseScreen> createState() => _AddVerseScreenState();
}

class _AddVerseScreenState extends State<AddVerseScreen> {
  final VerseService _verseService = VerseService();
  final CachedBibleApiService _bibleApiService = CachedBibleApiService(
    BibleServiceFactory.createService(),
  );
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  bool _isSaving = false;
  bool _isLoadingVerse = false;

  // Dropdown selections
  String? _selectedBook;
  int? _selectedChapter;
  int? _selectedVerse;

  @override
  void initState() {
    super.initState();
    if (widget.verse != null) {
      _referenceController.text = widget.verse!.reference;
      _textController.text = widget.verse!.text;
      _parseReference(widget.verse!.reference);
    }
  }

  void _parseReference(String reference) {
    // Try to parse "Book Chapter:Verse" format
    final parts = reference.split(' ');
    if (parts.length >= 2) {
      final bookName = parts.sublist(0, parts.length - 1).join(' ');
      final chapterVerse = parts.last;
      final cvParts = chapterVerse.split(':');
      
      if (cvParts.length == 2) {
        final book = BibleStructure.books.firstWhere(
          (b) => b.name == bookName,
          orElse: () => BibleStructure.books.first,
        );
        setState(() {
          _selectedBook = book.name;
          _selectedChapter = int.tryParse(cvParts[0]);
          _selectedVerse = int.tryParse(cvParts[1]);
        });
      }
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _fetchVerse() async {
    if (_selectedBook == null || _selectedChapter == null || _selectedVerse == null) {
      return;
    }

    setState(() {
      _isLoadingVerse = true;
    });

    final reference = BibleStructure.formatReference(
      _selectedBook!,
      _selectedChapter!,
      _selectedVerse!,
    );

    try {
      final verse = await _bibleApiService.getVerse(reference);
      if (verse != null && mounted) {
        setState(() {
          _referenceController.text = verse.reference;
          _textController.text = verse.text;
          _isLoadingVerse = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingVerse = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not fetch verse. Please enter manually.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingVerse = false;
        });
        
        // Check if it's a network error
        final errorMsg = e.toString().toLowerCase();
        final isNetworkError = errorMsg.contains('socketexception') ||
            errorMsg.contains('failed host lookup') ||
            errorMsg.contains('network');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNetworkError
                  ? 'No internet connection. Please check your network or enter verse manually.'
                  : 'Error fetching verse. Please enter manually.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveVerse() async {
    if (_referenceController.text.trim().isEmpty ||
        _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both reference and text')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final verse = Verse(
      id: widget.verse?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      reference: _referenceController.text.trim(),
      text: _textController.text.trim(),
      createdAt: widget.verse?.createdAt ?? now,
      updatedAt: now,
    );

    await _verseService.saveVerse(verse);
    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapters = _selectedBook != null
        ? BibleStructure.getChapterNumbers(_selectedBook!)
        : <int>[];
    final verses = (_selectedBook != null && _selectedChapter != null)
        ? BibleStructure.getVerseNumbers(_selectedBook!, _selectedChapter!)
        : <int>[];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.verse == null ? 'Add Verse' : 'Edit Verse',
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check, color: Colors.black),
            onPressed: _isSaving ? null : _saveVerse,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verse Selector Section
              Text(
                'Select Verse',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              // Book Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBook,
                decoration: InputDecoration(
                  labelText: 'Book',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: BibleStructure.books.map((book) {
                  return DropdownMenuItem<String>(
                    value: book.name,
                    child: Text(
                      book.name,
                      style: GoogleFonts.montserrat(),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBook = value;
                    _selectedChapter = null;
                    _selectedVerse = null;
                    _referenceController.clear();
                    _textController.clear();
                  });
                },
              ),
              const SizedBox(height: 16),
              // Chapter Dropdown
              DropdownButtonFormField<int>(
                value: _selectedChapter,
                decoration: InputDecoration(
                  labelText: 'Chapter',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: chapters.map((chapter) {
                  return DropdownMenuItem<int>(
                    value: chapter,
                    child: Text(
                      chapter.toString(),
                      style: GoogleFonts.montserrat(),
                    ),
                  );
                }).toList(),
                onChanged: _selectedBook == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedChapter = value;
                          _selectedVerse = null;
                          _referenceController.clear();
                          _textController.clear();
                        });
                      },
              ),
              const SizedBox(height: 16),
              // Verse Dropdown
              DropdownButtonFormField<int>(
                value: _selectedVerse,
                decoration: InputDecoration(
                  labelText: 'Verse',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: verses.map((verse) {
                  return DropdownMenuItem<int>(
                    value: verse,
                    child: Text(
                      verse.toString(),
                      style: GoogleFonts.montserrat(),
                    ),
                  );
                }).toList(),
                onChanged: (_selectedBook == null || _selectedChapter == null)
                    ? null
                    : (value) {
                        setState(() {
                          _selectedVerse = value;
                        });
                        _fetchVerse();
                      },
              ),
              if (_isLoadingVerse) ...[
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
              const SizedBox(height: 32),
              // Manual Entry Section
              Text(
                'Or enter manually',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              // Verse Reference
              TextField(
                controller: _referenceController,
                decoration: InputDecoration(
                  labelText: 'Verse Reference',
                  hintText: 'e.g., John 3:16',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: GoogleFonts.montserrat(),
              ),
              const SizedBox(height: 16),
              // Verse Text
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Verse Text',
                  hintText: 'Enter the verse text...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: GoogleFonts.montserrat(),
                maxLines: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

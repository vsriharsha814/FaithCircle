import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/verse.dart';
import '../services/verse_service.dart';
import 'add_verse_screen.dart';
import 'verse_detail_screen.dart';

class VerseLockerScreen extends StatefulWidget {
  const VerseLockerScreen({super.key});

  @override
  State<VerseLockerScreen> createState() => _VerseLockerScreenState();
}

class _VerseLockerScreenState extends State<VerseLockerScreen> {
  final VerseService _verseService = VerseService();
  List<Verse> _verses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVerses();
  }

  Future<void> _loadVerses() async {
    setState(() => _isLoading = true);
    final verses = await _verseService.getVerses();
    setState(() {
      _verses = verses;
      _isLoading = false;
    });
  }

  Future<void> _deleteVerse(Verse verse) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Verse',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${verse.reference}"?',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _verseService.deleteVerse(verse.id);
      _loadVerses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
              child: Text(
                'Verse Locker',
                style: GoogleFonts.montserrat(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            // Verses List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _verses.isEmpty
                      ? _buildEmptyState()
                      : _buildVersesList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addVerse(),
        backgroundColor: const Color(0xFF121212),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Saved Verses',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first verse',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersesList() {
    return RefreshIndicator(
      onRefresh: _loadVerses,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _verses.length,
        itemBuilder: (context, index) {
          final verse = _verses[index];
          return _buildVerseCard(verse);
        },
      ),
    );
  }

  Widget _buildVerseCard(Verse verse) {
    final preview = verse.text.length > 100
        ? '${verse.text.substring(0, 100)}...'
        : verse.text;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verse Reference
                    Text(
                      verse.reference,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Verse Text Preview
                    Text(
                      preview,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Quick Actions - Right aligned with reduced spacing
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _reviewVerse(verse),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.visibility_outlined,
                        size: 20,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _editVerse(verse),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _deleteVerse(verse),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Fine light line separator
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.shade200,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }

  Future<void> _addVerse() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddVerseScreen(),
      ),
    );

    if (result == true) {
      _loadVerses();
    }
  }

  Future<void> _reviewVerse(Verse verse) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerseDetailScreen(verse: verse),
      ),
    );
  }

  Future<void> _editVerse(Verse verse) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddVerseScreen(verse: verse),
      ),
    );

    if (result == true) {
      _loadVerses();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/personal_note.dart';
import '../models/sermon_note.dart';
import '../services/notes_service.dart';
import 'personal_note_detail_screen.dart';
import 'sermon_note_detail_screen.dart';

class SermonNotesScreen extends StatefulWidget {
  const SermonNotesScreen({super.key});

  @override
  State<SermonNotesScreen> createState() => _SermonNotesScreenState();
}

class _SermonNotesScreenState extends State<SermonNotesScreen> {
  final NotesService _notesService = NotesService();
  int _selectedSegment = 0; // 0 = Personal Notes, 1 = Sermon Notes
  List<PersonalNote> _personalNotes = [];
  List<SermonNote> _sermonNotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final personal = await _notesService.getPersonalNotes();
    final sermon = await _notesService.getSermonNotes();
    setState(() {
      _personalNotes = personal;
      _sermonNotes = sermon;
      _isLoading = false;
    });
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
                'Notes',
                style: GoogleFonts.montserrat(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            // Segmented Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSegmentedControl(),
            ),
            const SizedBox(height: 16),
            // Notes List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedSegment == 0
                      ? _buildPersonalNotesList()
                      : _buildSermonNotesList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewNote(),
        backgroundColor: const Color(0xFF121212),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegment(
              label: 'Personal Notes',
              isSelected: _selectedSegment == 0,
              onTap: () => setState(() => _selectedSegment = 0),
            ),
          ),
          Expanded(
            child: _buildSegment(
              label: 'Sermon Notes',
              isSelected: _selectedSegment == 1,
              onTap: () => setState(() => _selectedSegment = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF121212) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalNotesList() {
    if (_personalNotes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.note_outlined,
        title: 'No Personal Notes',
        message: 'Tap the + button to create your first personal note',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotes,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _personalNotes.length,
        itemBuilder: (context, index) {
          final note = _personalNotes[index];
          return _buildPersonalNoteCard(note);
        },
      ),
    );
  }

  Widget _buildSermonNotesList() {
    if (_sermonNotes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.menu_book,
        title: 'No Sermon Notes',
        message: 'Tap the + button to create your first sermon note',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotes,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _sermonNotes.length,
        itemBuilder: (context, index) {
          final note = _sermonNotes[index];
          return _buildSermonNoteCard(note);
        },
      ),
    );
  }

  Widget _buildPersonalNoteCard(PersonalNote note) {
    final preview = note.content.length > 100
        ? '${note.content.substring(0, 100)}...'
        : note.content;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: const Color(0xFFFFF8E1), // Warm light yellow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _openPersonalNote(note),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title.isEmpty ? 'Untitled' : note.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                preview,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Text(
                _formatDate(note.updatedAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSermonNoteCard(SermonNote note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: const Color(0xFFFFF8E1), // Warm light yellow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _openSermonNote(note),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title.isEmpty ? 'Untitled' : note.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (note.scripture != null && note.scripture!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.book, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      note.scripture!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
              if (note.mainPoints.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${note.mainPoints.length} main point${note.mainPoints.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                _formatDate(note.updatedAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  void _createNewNote() {
    if (_selectedSegment == 0) {
      _openPersonalNote(null);
    } else {
      _openSermonNote(null);
    }
  }

  Future<void> _openPersonalNote(PersonalNote? note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalNoteDetailScreen(note: note),
      ),
    );

    if (result == true) {
      _loadNotes();
    }
  }

  Future<void> _openSermonNote(SermonNote? note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SermonNoteDetailScreen(note: note),
      ),
    );

    if (result == true) {
      _loadNotes();
    }
  }
}

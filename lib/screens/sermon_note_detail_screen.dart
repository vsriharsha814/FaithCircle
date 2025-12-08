import 'package:flutter/material.dart';
import '../models/sermon_note.dart';
import '../services/notes_service.dart';

class SermonNoteDetailScreen extends StatefulWidget {
  final SermonNote? note;

  const SermonNoteDetailScreen({super.key, this.note});

  @override
  State<SermonNoteDetailScreen> createState() => _SermonNoteDetailScreenState();
}

class _SermonNoteDetailScreenState extends State<SermonNoteDetailScreen> {
  final NotesService _notesService = NotesService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _scriptureController = TextEditingController();
  final TextEditingController _takeawaysController = TextEditingController();
  final TextEditingController _actionStepsController = TextEditingController();
  final List<TextEditingController> _mainPointControllers = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _scriptureController.text = widget.note!.scripture ?? '';
      _takeawaysController.text = widget.note!.takeaways;
      _actionStepsController.text = widget.note!.actionSteps;
      _mainPointControllers.addAll(
        widget.note!.mainPoints.map((point) => TextEditingController(text: point)),
      );
    } else {
      // Start with one empty main point field
      _mainPointControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _scriptureController.dispose();
    _takeawaysController.dispose();
    _actionStepsController.dispose();
    for (var controller in _mainPointControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addMainPoint() {
    setState(() {
      _mainPointControllers.add(TextEditingController());
    });
  }

  void _removeMainPoint(int index) {
    if (_mainPointControllers.length > 1) {
      setState(() {
        _mainPointControllers[index].dispose();
        _mainPointControllers.removeAt(index);
      });
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final mainPoints = _mainPointControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final now = DateTime.now();
    final note = SermonNote(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      scripture: _scriptureController.text.trim().isEmpty
          ? null
          : _scriptureController.text.trim(),
      mainPoints: mainPoints,
      takeaways: _takeawaysController.text.trim(),
      actionSteps: _actionStepsController.text.trim(),
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
    );

    await _notesService.saveSermonNote(note);
    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteNote() async {
    if (widget.note == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this sermon note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _notesService.deleteSermonNote(widget.note!.id);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteNote,
            ),
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check, color: Colors.black),
            onPressed: _isSaving ? null : _saveNote,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Sermon Title',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              // Scripture
              _buildSectionTitle('Scripture Reference'),
              const SizedBox(height: 8),
              TextField(
                controller: _scriptureController,
                decoration: InputDecoration(
                  hintText: 'e.g., John 3:16',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 24),

              // Main Points
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Main Points'),
                  TextButton.icon(
                    onPressed: _addMainPoint,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Point'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF121212),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(
                _mainPointControllers.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _mainPointControllers[index],
                          decoration: InputDecoration(
                            hintText: 'Main point ${index + 1}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                '${index + 1}.',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_mainPointControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeMainPoint(index),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Takeaways
              _buildSectionTitle('Takeaways'),
              const SizedBox(height: 8),
              TextField(
                controller: _takeawaysController,
                decoration: InputDecoration(
                  hintText: 'What did you learn?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Action Steps
              _buildSectionTitle('Action Steps'),
              const SizedBox(height: 8),
              TextField(
                controller: _actionStepsController,
                decoration: InputDecoration(
                  hintText: 'What will you do differently?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }
}


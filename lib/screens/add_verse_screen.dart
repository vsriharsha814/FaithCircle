import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/verse.dart';
import '../services/verse_service.dart';

class AddVerseScreen extends StatefulWidget {
  final Verse? verse;

  const AddVerseScreen({super.key, this.verse});

  @override
  State<AddVerseScreen> createState() => _AddVerseScreenState();
}

class _AddVerseScreenState extends State<AddVerseScreen> {
  final VerseService _verseService = VerseService();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSaving = false;
  bool _showSearchResults = false;
  List<Map<String, String>> _searchResults = [];

  // Sample Bible verses for search (in a real app, this would come from an API)
  final List<Map<String, String>> _sampleVerses = [
    {'reference': 'John 3:16', 'text': 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.'},
    {'reference': 'Philippians 4:13', 'text': 'I can do all this through him who gives me strength.'},
    {'reference': 'Jeremiah 29:11', 'text': 'For I know the plans I have for you," declares the Lord, "plans to prosper you and not to harm you, plans to give you hope and a future.'},
    {'reference': 'Romans 8:28', 'text': 'And we know that in all things God works for the good of those who love him, who have been called according to his purpose.'},
    {'reference': 'Proverbs 3:5-6', 'text': 'Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.'},
    {'reference': 'Isaiah 41:10', 'text': 'So do not fear, for I am with you; do not be dismayed, for I am your God. I will strengthen you and help you; I will uphold you with my righteous right hand.'},
    {'reference': 'Matthew 28:20', 'text': 'And surely I am with you always, to the very end of the age.'},
    {'reference': 'Joshua 1:9', 'text': 'Have I not commanded you? Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.'},
    {'reference': '1 Corinthians 13:4-5', 'text': 'Love is patient, love is kind. It does not envy, it does not boast, it is not proud. It does not dishonor others, it is not self-seeking, it is not easily angered, it keeps no record of wrongs.'},
    {'reference': 'Psalm 23:1', 'text': 'The Lord is my shepherd, I lack nothing.'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.verse != null) {
      _referenceController.text = widget.verse!.reference;
      _textController.text = widget.verse!.text;
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _textController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _showSearchResults = true;
      _searchResults = _sampleVerses
          .where((verse) =>
              verse['reference']!.toLowerCase().contains(query) ||
              verse['text']!.toLowerCase().contains(query))
          .toList();
    });
  }

  void _selectSearchResult(Map<String, String> result) {
    setState(() {
      _referenceController.text = result['reference']!;
      _textController.text = result['text']!;
      _searchController.clear();
      _showSearchResults = false;
    });
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
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Bible verses...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _showSearchResults = false;
                              _searchResults = [];
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              // Search Results
              if (_showSearchResults && _searchResults.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return ListTile(
                        title: Text(
                          result['reference']!,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          result['text']!,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _selectSearchResult(result),
                      );
                    },
                  ),
                ),
              ],
              if (_showSearchResults && _searchResults.isEmpty &&
                  _searchController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No verses found. Try a different search or enter manually.',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Manual Entry Section
              Text(
                'Or enter manually',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
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


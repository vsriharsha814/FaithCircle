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
  
  // Range selection mode
  bool _isRangeMode = false;
  int? _selectedFromVerse;
  int? _selectedToVerse;
  
  // Menu controllers for MenuAnchor
  final MenuController _bookMenuController = MenuController();
  final MenuController _chapterMenuController = MenuController();
  final MenuController _verseMenuController = MenuController();
  final MenuController _fromVerseMenuController = MenuController();
  final MenuController _toVerseMenuController = MenuController();

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
    if (_selectedBook == null || _selectedChapter == null) {
      return;
    }

    // Check if range mode or single verse mode
    if (_isRangeMode) {
      if (_selectedFromVerse == null || _selectedToVerse == null) {
        return;
      }
      if (_selectedFromVerse! > _selectedToVerse!) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('From verse must be less than or equal to To verse.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      await _fetchVerseRange();
    } else {
      if (_selectedVerse == null) {
        return;
      }
      await _fetchSingleVerse();
    }
  }

  Future<void> _fetchSingleVerse() async {
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
        _handleFetchError(e);
      }
    }
  }

  Future<void> _fetchVerseRange() async {
    setState(() {
      _isLoadingVerse = true;
    });

    try {
      final List<String> verseTexts = [];
      
      // Fetch each verse in the range
      for (int verseNum = _selectedFromVerse!; verseNum <= _selectedToVerse!; verseNum++) {
        final reference = BibleStructure.formatReference(
          _selectedBook!,
          _selectedChapter!,
          verseNum,
        );
        
        final verse = await _bibleApiService.getVerse(reference);
        if (verse != null) {
          verseTexts.add(verse.text);
        }
      }

      if (verseTexts.isNotEmpty && mounted) {
        // Format reference as "Book Chapter:FromVerse-ToVerse"
        final reference = '${_selectedBook} ${_selectedChapter}:${_selectedFromVerse}-${_selectedToVerse}';
        final combinedText = verseTexts.join(' ');
        
        setState(() {
          _referenceController.text = reference;
          _textController.text = combinedText;
          _isLoadingVerse = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingVerse = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not fetch verses. Please enter manually.'),
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
        _handleFetchError(e);
      }
    }
  }

  void _handleFetchError(dynamic e) {
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
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              // Book Dropdown
              _buildModernDropdown<String>(
                label: 'Book',
                icon: Icons.menu_book_outlined,
                value: _selectedBook,
                items: BibleStructure.books.map((book) {
                  return DropdownMenuItem<String>(
                    value: book.name,
                    child: Text(
                      book.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
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
                menuController: _bookMenuController,
              ),
              const SizedBox(height: 16),
              // Chapter Dropdown with Range Toggle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildModernDropdown<int>(
                          label: 'Chapter',
                          icon: Icons.looks_one_outlined,
                          value: _selectedChapter,
                          items: chapters.map((chapter) {
                            return DropdownMenuItem<int>(
                              value: chapter,
                              child: Text(
                                chapter.toString(),
                                style: GoogleFonts.montserrat(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: _selectedBook == null
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedChapter = value;
                                    _selectedVerse = null;
                                    _selectedFromVerse = null;
                                    _selectedToVerse = null;
                                    _referenceController.clear();
                                    _textController.clear();
                                  });
                                },
                          menuController: _chapterMenuController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Compact Range Toggle with Label
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: _isRangeMode ? const Color(0xFF121212) : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isRangeMode ? const Color(0xFF121212) : Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: (_selectedBook == null || _selectedChapter == null)
                                    ? null
                                    : () {
                                        setState(() {
                                          _isRangeMode = !_isRangeMode;
                                          if (_isRangeMode) {
                                            // Switch to range mode - clear single verse
                                            _selectedVerse = null;
                                          } else {
                                            // Switch to single mode - clear range
                                            _selectedFromVerse = null;
                                            _selectedToVerse = null;
                                          }
                                          _referenceController.clear();
                                          _textController.clear();
                                        });
                                      },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.linear_scale,
                                    color: _isRangeMode ? Colors.white : Colors.grey.shade600,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Range',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _isRangeMode ? const Color(0xFF121212) : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_isRangeMode) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121212).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Select multiple verses',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              // Verse Selection (Single or Range)
              if (!_isRangeMode) ...[
                // Single Verse Dropdown
                _buildModernDropdown<int>(
                  label: 'Verse',
                  icon: Icons.format_list_numbered_outlined,
                  value: _selectedVerse,
                  items: verses.map((verse) {
                    return DropdownMenuItem<int>(
                      value: verse,
                      child: Text(
                        verse.toString(),
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
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
                  menuController: _verseMenuController,
                ),
              ] else ...[
                // Range Selection - From Verse
                Row(
                  children: [
                    Expanded(
                      child: _buildModernDropdown<int>(
                        label: 'From Verse',
                        icon: Icons.play_arrow_outlined,
                        value: _selectedFromVerse,
                        items: verses.map((verse) {
                          return DropdownMenuItem<int>(
                            value: verse,
                            child: Text(
                              verse.toString(),
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (_selectedBook == null || _selectedChapter == null)
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedFromVerse = value;
                                  // Reset to verse if from > to
                                  if (_selectedToVerse != null && value != null && value > _selectedToVerse!) {
                                    _selectedToVerse = null;
                                  }
                                });
                                if (_selectedFromVerse != null && _selectedToVerse != null) {
                                  _fetchVerse();
                                }
                              },
                        menuController: _fromVerseMenuController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModernDropdown<int>(
                        label: 'To Verse',
                        icon: Icons.stop_outlined,
                        value: _selectedToVerse,
                        items: verses
                            .where((verse) => _selectedFromVerse == null || verse >= _selectedFromVerse!)
                            .map((verse) {
                          return DropdownMenuItem<int>(
                            value: verse,
                            child: Text(
                              verse.toString(),
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (_selectedBook == null || _selectedChapter == null || _selectedFromVerse == null)
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedToVerse = value;
                                });
                                if (_selectedFromVerse != null && _selectedToVerse != null) {
                                  _fetchVerse();
                                }
                              },
                        menuController: _toVerseMenuController,
                      ),
                    ),
                  ],
                ),
              ],
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

  Widget _buildModernDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    required MenuController menuController,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Menu width should match the dropdown box width exactly
        // The parent SingleChildScrollView has 16px padding on each side
        // So the available width is screen width - 32px
        // The dropdown box uses the full constraints.maxWidth
        final boxWidth = constraints.maxWidth;
        
        return MenuAnchor(
          controller: menuController,
          alignmentOffset: const Offset(0, 4), // Small offset for spacing
          crossAxisUnconstrained: false, // Constrain menu to not exceed bounds
          style: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Colors.white),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: Color(0xFFE0E0E0), // Light grey border
                  width: 1.5,
                ),
              ),
            ),
            elevation: WidgetStateProperty.all(0), // Remove shadow
            padding: WidgetStateProperty.all(
              EdgeInsets.zero, // Remove padding to match box width exactly
            ),
            // Menu width matches box width exactly
            minimumSize: WidgetStateProperty.all(Size(boxWidth, 0)),
            maximumSize: WidgetStateProperty.all(
              Size(boxWidth, 300),
            ),
          ),
          menuChildren: items.map((item) {
            return MenuItemButton(
              onPressed: () {
                if (onChanged != null) {
                  onChanged(item.value);
                }
                menuController.close();
              },
              style: MenuItemButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: SizedBox(
                width: boxWidth, // Match the box width exactly
                child: item.child,
              ),
            );
          }).toList(),
          builder: (context, controller, child) {
            return InkWell(
              onTap: onChanged == null
                  ? null
                  : () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: value != null ? const Color(0xFF121212) : Colors.grey.shade300,
                    width: value != null ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: value != null ? const Color(0xFF121212) : Colors.grey.shade600,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: value != null ? const Color(0xFF121212) : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            value != null ? value.toString() : 'Select $label',
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: value != null ? Colors.black : Colors.grey.shade400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: value != null ? const Color(0xFF121212) : Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

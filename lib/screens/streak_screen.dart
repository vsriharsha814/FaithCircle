import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/notes_service.dart';
import '../services/verse_service.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Set<DateTime> _daysWithNotes = {};
  bool _isLoading = true;

  final NotesService _notesService = NotesService();
  final VerseService _verseService = VerseService();

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadNotesDates();
  }

  Future<void> _loadNotesDates() async {
    setState(() {
      _isLoading = true;
    });

    final Set<DateTime> datesWithNotes = {};

    // Load personal notes
    final personalNotes = await _notesService.getPersonalNotes();
    for (var note in personalNotes) {
      final date = DateTime(note.noteDate.year, note.noteDate.month, note.noteDate.day);
      datesWithNotes.add(date);
    }

    // Load sermon notes
    final sermonNotes = await _notesService.getSermonNotes();
    for (var note in sermonNotes) {
      final date = DateTime(note.noteDate.year, note.noteDate.month, note.noteDate.day);
      datesWithNotes.add(date);
    }

    // Load verses (using createdAt date)
    final verses = await _verseService.getVerses();
    for (var verse in verses) {
      final date = DateTime(verse.createdAt.year, verse.createdAt.month, verse.createdAt.day);
      datesWithNotes.add(date);
    }

    if (mounted) {
      setState(() {
        _daysWithNotes = datesWithNotes;
        _isLoading = false;
      });
    }
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return _isSameDay(day, now);
  }

  bool _isFuture(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayOnly = DateTime(day.year, day.month, day.day);
    return dayOnly.isAfter(today);
  }

  bool _hasNote(DateTime day) {
    return _daysWithNotes.any((date) => _isSameDay(day, date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Streak',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: _loadNotesDates,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calendar
                      TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => _isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarFormat: CalendarFormat.month,
                        startingDayOfWeek: StartingDayOfWeek.sunday,
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          weekendTextStyle: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          defaultTextStyle: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: const Color(0xFF121212),
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          todayTextStyle: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          disabledTextStyle: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade300,
                          ),
                          markerDecoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          leftChevronIcon: const Icon(
                            Icons.chevron_left,
                            color: Colors.black,
                          ),
                          rightChevronIcon: const Icon(
                            Icons.chevron_right,
                            color: Colors.black,
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                          weekendStyle: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, date, _) {
                            final isFuture = _isFuture(date);
                            final hasNote = _hasNote(date);
                            
                            return Center(
                              child: hasNote
                                  ? Icon(
                                      Icons.local_fire_department,
                                      size: 18,
                                      color: Colors.orange.shade400,
                                    )
                                  : Text(
                                      '${date.day}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isFuture
                                            ? Colors.grey.shade300
                                            : Colors.black,
                                      ),
                                    ),
                            );
                          },
                          todayBuilder: (context, date, _) {
                            final hasNote = _hasNote(date);
                            
                            return Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: hasNote
                                    ? Icon(
                                        Icons.local_fire_department,
                                        size: 18,
                                        color: Colors.orange.shade400,
                                      )
                                    : Text(
                                        '${date.day}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                              ),
                            );
                          },
                          selectedBuilder: (context, date, _) {
                            final hasNote = _hasNote(date);
                            
                            return Container(
                              margin: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF121212),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: hasNote
                                    ? Icon(
                                        Icons.local_fire_department,
                                        size: 18,
                                        color: Colors.orange.shade400,
                                      )
                                    : Text(
                                        '${date.day}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          },
                          outsideBuilder: (context, date, _) {
                            final isFuture = _isFuture(date);
                            final hasNote = _hasNote(date);
                            
                            return Center(
                              child: hasNote
                                  ? Icon(
                                      Icons.local_fire_department,
                                      size: 18,
                                      color: Colors.orange.shade400,
                                    )
                                  : Text(
                                      '${date.day}',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: isFuture
                                            ? Colors.grey.shade300
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Legend
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 20,
                              color: Colors.orange.shade400,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Day with notes',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

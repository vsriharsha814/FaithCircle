class BibleBook {
  final String name;
  final String abbreviation;
  final int chapters;

  BibleBook({
    required this.name,
    required this.abbreviation,
    required this.chapters,
  });
}

class BibleStructure {
  static final List<BibleBook> books = [
    // Old Testament
    BibleBook(name: 'Genesis', abbreviation: 'Gen', chapters: 50),
    BibleBook(name: 'Exodus', abbreviation: 'Exod', chapters: 40),
    BibleBook(name: 'Leviticus', abbreviation: 'Lev', chapters: 27),
    BibleBook(name: 'Numbers', abbreviation: 'Num', chapters: 36),
    BibleBook(name: 'Deuteronomy', abbreviation: 'Deut', chapters: 34),
    BibleBook(name: 'Joshua', abbreviation: 'Josh', chapters: 24),
    BibleBook(name: 'Judges', abbreviation: 'Judg', chapters: 21),
    BibleBook(name: 'Ruth', abbreviation: 'Ruth', chapters: 4),
    BibleBook(name: '1 Samuel', abbreviation: '1Sam', chapters: 31),
    BibleBook(name: '2 Samuel', abbreviation: '2Sam', chapters: 24),
    BibleBook(name: '1 Kings', abbreviation: '1Kgs', chapters: 22),
    BibleBook(name: '2 Kings', abbreviation: '2Kgs', chapters: 25),
    BibleBook(name: '1 Chronicles', abbreviation: '1Chr', chapters: 29),
    BibleBook(name: '2 Chronicles', abbreviation: '2Chr', chapters: 36),
    BibleBook(name: 'Ezra', abbreviation: 'Ezra', chapters: 10),
    BibleBook(name: 'Nehemiah', abbreviation: 'Neh', chapters: 13),
    BibleBook(name: 'Esther', abbreviation: 'Esth', chapters: 10),
    BibleBook(name: 'Job', abbreviation: 'Job', chapters: 42),
    BibleBook(name: 'Psalm', abbreviation: 'Ps', chapters: 150),
    BibleBook(name: 'Proverbs', abbreviation: 'Prov', chapters: 31),
    BibleBook(name: 'Ecclesiastes', abbreviation: 'Eccl', chapters: 12),
    BibleBook(name: 'Song of Songs', abbreviation: 'Song', chapters: 8),
    BibleBook(name: 'Isaiah', abbreviation: 'Isa', chapters: 66),
    BibleBook(name: 'Jeremiah', abbreviation: 'Jer', chapters: 52),
    BibleBook(name: 'Lamentations', abbreviation: 'Lam', chapters: 5),
    BibleBook(name: 'Ezekiel', abbreviation: 'Ezek', chapters: 48),
    BibleBook(name: 'Daniel', abbreviation: 'Dan', chapters: 12),
    BibleBook(name: 'Hosea', abbreviation: 'Hos', chapters: 14),
    BibleBook(name: 'Joel', abbreviation: 'Joel', chapters: 3),
    BibleBook(name: 'Amos', abbreviation: 'Amos', chapters: 9),
    BibleBook(name: 'Obadiah', abbreviation: 'Obad', chapters: 1),
    BibleBook(name: 'Jonah', abbreviation: 'Jonah', chapters: 4),
    BibleBook(name: 'Micah', abbreviation: 'Mic', chapters: 7),
    BibleBook(name: 'Nahum', abbreviation: 'Nah', chapters: 3),
    BibleBook(name: 'Habakkuk', abbreviation: 'Hab', chapters: 3),
    BibleBook(name: 'Zephaniah', abbreviation: 'Zeph', chapters: 3),
    BibleBook(name: 'Haggai', abbreviation: 'Hag', chapters: 2),
    BibleBook(name: 'Zechariah', abbreviation: 'Zech', chapters: 14),
    BibleBook(name: 'Malachi', abbreviation: 'Mal', chapters: 4),
    
    // New Testament
    BibleBook(name: 'Matthew', abbreviation: 'Matt', chapters: 28),
    BibleBook(name: 'Mark', abbreviation: 'Mark', chapters: 16),
    BibleBook(name: 'Luke', abbreviation: 'Luke', chapters: 24),
    BibleBook(name: 'John', abbreviation: 'John', chapters: 21),
    BibleBook(name: 'Acts', abbreviation: 'Acts', chapters: 28),
    BibleBook(name: 'Romans', abbreviation: 'Rom', chapters: 16),
    BibleBook(name: '1 Corinthians', abbreviation: '1Cor', chapters: 16),
    BibleBook(name: '2 Corinthians', abbreviation: '2Cor', chapters: 13),
    BibleBook(name: 'Galatians', abbreviation: 'Gal', chapters: 6),
    BibleBook(name: 'Ephesians', abbreviation: 'Eph', chapters: 6),
    BibleBook(name: 'Philippians', abbreviation: 'Phil', chapters: 4),
    BibleBook(name: 'Colossians', abbreviation: 'Col', chapters: 4),
    BibleBook(name: '1 Thessalonians', abbreviation: '1Thess', chapters: 5),
    BibleBook(name: '2 Thessalonians', abbreviation: '2Thess', chapters: 3),
    BibleBook(name: '1 Timothy', abbreviation: '1Tim', chapters: 6),
    BibleBook(name: '2 Timothy', abbreviation: '2Tim', chapters: 4),
    BibleBook(name: 'Titus', abbreviation: 'Titus', chapters: 3),
    BibleBook(name: 'Philemon', abbreviation: 'Phlm', chapters: 1),
    BibleBook(name: 'Hebrews', abbreviation: 'Heb', chapters: 13),
    BibleBook(name: 'James', abbreviation: 'Jas', chapters: 5),
    BibleBook(name: '1 Peter', abbreviation: '1Pet', chapters: 5),
    BibleBook(name: '2 Peter', abbreviation: '2Pet', chapters: 3),
    BibleBook(name: '1 John', abbreviation: '1John', chapters: 5),
    BibleBook(name: '2 John', abbreviation: '2John', chapters: 1),
    BibleBook(name: '3 John', abbreviation: '3John', chapters: 1),
    BibleBook(name: 'Jude', abbreviation: 'Jude', chapters: 1),
    BibleBook(name: 'Revelation', abbreviation: 'Rev', chapters: 22),
  ];

  // Approximate verses per chapter (varies, but this gives a reasonable max)
  // For most chapters, verses range from 10-50, with some exceptions
  static int getMaxVersesForChapter(String bookName, int chapter) {
    // Some books have very long chapters
    if (bookName == 'Psalm' && chapter == 119) return 176;
    if (bookName == 'Esther' && chapter == 9) return 32;
    if (bookName == 'Job' && chapter == 42) return 17;
    
    // Most chapters have 30-50 verses max
    return 50;
  }

  static List<int> getChapterNumbers(String bookName) {
    final book = books.firstWhere(
      (b) => b.name == bookName,
      orElse: () => BibleBook(name: bookName, abbreviation: '', chapters: 0),
    );
    return List.generate(book.chapters, (index) => index + 1);
  }

  static List<int> getVerseNumbers(String bookName, int chapter) {
    final maxVerses = getMaxVersesForChapter(bookName, chapter);
    return List.generate(maxVerses, (index) => index + 1);
  }

  static String formatReference(String bookName, int chapter, int verse) {
    return '$bookName $chapter:$verse';
  }
}


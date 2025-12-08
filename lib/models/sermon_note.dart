class SermonNote {
  final String id;
  final String title;
  final String? scripture;
  final List<String> mainPoints;
  final String takeaways;
  final String actionSteps;
  final String notes;
  final DateTime noteDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SermonNote({
    required this.id,
    required this.title,
    this.scripture,
    required this.mainPoints,
    required this.takeaways,
    required this.actionSteps,
    required this.notes,
    required this.noteDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'scripture': scripture,
      'mainPoints': mainPoints,
      'takeaways': takeaways,
      'actionSteps': actionSteps,
      'notes': notes,
      'noteDate': noteDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SermonNote.fromJson(Map<String, dynamic> json) {
    return SermonNote(
      id: json['id'] as String,
      title: json['title'] as String,
      scripture: json['scripture'] as String?,
      mainPoints: List<String>.from(json['mainPoints'] as List),
      takeaways: json['takeaways'] as String? ?? '',
      actionSteps: json['actionSteps'] as String? ?? '',
      notes: json.containsKey('notes') && json['notes'] != null 
          ? json['notes'] as String 
          : '',
      noteDate: json['noteDate'] != null
          ? DateTime.parse(json['noteDate'] as String)
          : DateTime.parse(json['createdAt'] as String), // Fallback for old notes
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  SermonNote copyWith({
    String? id,
    String? title,
    String? scripture,
    List<String>? mainPoints,
    String? takeaways,
    String? actionSteps,
    String? notes,
    DateTime? noteDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SermonNote(
      id: id ?? this.id,
      title: title ?? this.title,
      scripture: scripture ?? this.scripture,
      mainPoints: mainPoints ?? this.mainPoints,
      takeaways: takeaways ?? this.takeaways,
      actionSteps: actionSteps ?? this.actionSteps,
      notes: notes ?? this.notes,
      noteDate: noteDate ?? this.noteDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


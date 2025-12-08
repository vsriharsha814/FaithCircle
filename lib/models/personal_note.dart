class PersonalNote {
  final String id;
  final String title;
  final String content;
  final DateTime noteDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  PersonalNote({
    required this.id,
    required this.title,
    required this.content,
    required this.noteDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'noteDate': noteDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PersonalNote.fromJson(Map<String, dynamic> json) {
    return PersonalNote(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      noteDate: json['noteDate'] != null
          ? DateTime.parse(json['noteDate'] as String)
          : DateTime.parse(json['createdAt'] as String), // Fallback for old notes
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  PersonalNote copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? noteDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonalNote(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      noteDate: noteDate ?? this.noteDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


class Verse {
  final String id;
  final String reference;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  Verse({
    required this.id,
    required this.reference,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'] as String,
      reference: json['reference'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Verse copyWith({
    String? id,
    String? reference,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Verse(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


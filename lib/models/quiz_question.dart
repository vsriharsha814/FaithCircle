class QuizQuestion {
  final String id;
  final String category;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String? scriptureReference;

  QuizQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.scriptureReference,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'scriptureReference': scriptureReference,
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      category: json['category'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      scriptureReference: json['scriptureReference'] as String?,
    );
  }
}


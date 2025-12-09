import '../models/quiz_question.dart';

class QuizService {
  // Sample Bible quiz questions - you can expand this with more questions
  static List<QuizQuestion> getSampleQuestions() {
    return [
      // Gospels Category
      QuizQuestion(
        id: '1',
        category: 'Gospels',
        question: 'Who baptized Jesus in the Jordan River?',
        options: [
          'John the Baptist',
          'Peter',
          'Paul',
          'James',
        ],
        correctAnswerIndex: 0,
        scriptureReference: 'Matthew 3:13-17',
      ),
      QuizQuestion(
        id: '2',
        category: 'Gospels',
        question: 'How many disciples did Jesus have?',
        options: [
          '10',
          '12',
          '14',
          '16',
        ],
        correctAnswerIndex: 1,
        scriptureReference: 'Matthew 10:1-4',
      ),
      QuizQuestion(
        id: '3',
        category: 'Gospels',
        question: 'What was the first miracle Jesus performed?',
        options: [
          'Walking on water',
          'Feeding the 5,000',
          'Turning water into wine',
          'Raising Lazarus',
        ],
        correctAnswerIndex: 2,
        scriptureReference: 'John 2:1-11',
      ),
      QuizQuestion(
        id: '4',
        category: 'Gospels',
        question: 'Where was Jesus born?',
        options: [
          'Nazareth',
          'Jerusalem',
          'Bethlehem',
          'Galilee',
        ],
        correctAnswerIndex: 2,
        scriptureReference: 'Luke 2:4-7',
      ),
      QuizQuestion(
        id: '5',
        category: 'Gospels',
        question: 'What did Jesus say is the greatest commandment?',
        options: [
          'Love your neighbor',
          'Do not steal',
          'Love the Lord your God',
          'Honor your father and mother',
        ],
        correctAnswerIndex: 2,
        scriptureReference: 'Matthew 22:36-40',
      ),
      // Life of Jesus Category
      QuizQuestion(
        id: '6',
        category: 'Life of Jesus',
        question: 'How old was Jesus when he began his ministry?',
        options: [
          '25',
          '30',
          '33',
          '35',
        ],
        correctAnswerIndex: 1,
        scriptureReference: 'Luke 3:23',
      ),
      QuizQuestion(
        id: '7',
        category: 'Life of Jesus',
        question: 'How many days was Jesus in the wilderness being tempted?',
        options: [
          '30 days',
          '40 days',
          '50 days',
          '60 days',
        ],
        correctAnswerIndex: 1,
        scriptureReference: 'Matthew 4:1-2',
      ),
      QuizQuestion(
        id: '8',
        category: 'Life of Jesus',
        question: 'Who denied Jesus three times?',
        options: [
          'Judas',
          'Peter',
          'Thomas',
          'John',
        ],
        correctAnswerIndex: 1,
        scriptureReference: 'Matthew 26:69-75',
      ),
      QuizQuestion(
        id: '9',
        category: 'Life of Jesus',
        question: 'How many days after his death did Jesus rise from the dead?',
        options: [
          '2 days',
          '3 days',
          '4 days',
          '7 days',
        ],
        correctAnswerIndex: 1,
        scriptureReference: 'Matthew 28:1-6',
      ),
      QuizQuestion(
        id: '10',
        category: 'Life of Jesus',
        question: 'What was the last thing Jesus said on the cross?',
        options: [
          'Father, forgive them',
          'It is finished',
          'My God, my God, why have you forsaken me?',
          'Today you will be with me in paradise',
        ],
        correctAnswerIndex: 1,
        scriptureReference: 'John 19:30',
      ),
    ];
  }

  static List<QuizQuestion> getQuestionsByCategory(String category) {
    return getSampleQuestions()
        .where((q) => q.category == category)
        .toList();
  }

  static List<String> getCategories() {
    return getSampleQuestions()
        .map((q) => q.category)
        .toSet()
        .toList();
  }
}


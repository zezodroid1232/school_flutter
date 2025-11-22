class ExamModel {
  final String id;
  final String title;
  final String teacherId;
  final int timestamp;
  final List<QuestionModel> questions;

  ExamModel({
    required this.id,
    required this.title,
    required this.teacherId,
    required this.timestamp,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'teacherId': teacherId,
      'timestamp': timestamp,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  factory ExamModel.fromMap(Map<String, dynamic> map) {
    return ExamModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      teacherId: map['teacherId'] ?? '',
      timestamp: map['timestamp'] ?? 0,
      questions:
          (map['questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromMap(Map<String, dynamic>.from(q)))
              .toList() ??
          [],
    );
  }
}

class QuestionModel {
  final String question;
  final String type; // 'text', 'multiple_choice'
  final List<String>? options;
  final String? correctAnswer; // For auto-grading if needed

  QuestionModel({
    required this.question,
    required this.type,
    this.options,
    this.correctAnswer,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'type': type,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      question: map['question'] ?? '',
      type: map['type'] ?? 'text',
      options: (map['options'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      correctAnswer: map['correctAnswer'],
    );
  }
}

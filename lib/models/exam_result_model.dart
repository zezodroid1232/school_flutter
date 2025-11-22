class ExamResultModel {
  final String id;
  final String examId;
  final String studentId;
  final String studentName;
  final int score;
  final int totalScore;
  final Map<String, dynamic> answers; // Question Index -> Answer
  final int timestamp;

  ExamResultModel({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.studentName,
    required this.score,
    required this.totalScore,
    required this.answers,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'examId': examId,
      'studentId': studentId,
      'studentName': studentName,
      'score': score,
      'totalScore': totalScore,
      'answers': answers,
      'timestamp': timestamp,
    };
  }

  factory ExamResultModel.fromMap(Map<String, dynamic> map) {
    return ExamResultModel(
      id: map['id'] ?? '',
      examId: map['examId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      score: map['score'] ?? 0,
      totalScore: map['totalScore'] ?? 0,
      answers: Map<String, dynamic>.from(map['answers'] ?? {}),
      timestamp: map['timestamp'] ?? 0,
    );
  }
}

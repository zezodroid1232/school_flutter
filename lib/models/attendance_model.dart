class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final int date; // Timestamp
  final bool isPresent;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.isPresent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'date': date,
      'isPresent': isPresent,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      date: map['date'] ?? 0,
      isPresent: map['isPresent'] ?? false,
    );
  }
}

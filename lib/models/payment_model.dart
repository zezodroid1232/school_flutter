class PaymentModel {
  final String id;
  final String studentId;
  final String studentName;
  final double amount;
  final int date; // Timestamp
  final String month; // e.g., "October 2023"
  final String? note;

  PaymentModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.amount,
    required this.date,
    required this.month,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'amount': amount,
      'date': date,
      'month': month,
      'note': note,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] ?? 0,
      month: map['month'] ?? '',
      note: map['note'],
    );
  }
}

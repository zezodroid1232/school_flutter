import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import '../models/exam_model.dart';
import '../models/exam_result_model.dart';
import '../models/payment_model.dart';
import '../models/attendance_model.dart';

class DataService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Get all teachers
  Stream<List<UserModel>> getTeachers() {
    return _dbRef
        .child('users')
        .orderByChild('role')
        .equalTo('teacher')
        .onValue
        .map((event) {
          final List<UserModel> teachers = [];
          if (event.snapshot.value != null) {
            final Map<dynamic, dynamic> map =
                event.snapshot.value as Map<dynamic, dynamic>;
            map.forEach((key, value) {
              teachers.add(UserModel.fromMap(Map<String, dynamic>.from(value)));
            });
          }
          return teachers;
        });
  }

  // Student requests to join a teacher
  Future<void> requestJoinTeacher(String studentId, String teacherId) async {
    await _dbRef.child('users').child(studentId).update({
      'teacherId': teacherId,
      'isActive': false,
    });
  }

  // Get students for a specific teacher
  Stream<List<UserModel>> getStudentsForTeacher(String teacherId) {
    return _dbRef
        .child('users')
        .orderByChild('teacherId')
        .equalTo(teacherId)
        .onValue
        .map((event) {
          final List<UserModel> students = [];
          if (event.snapshot.value != null) {
            final Map<dynamic, dynamic> map =
                event.snapshot.value as Map<dynamic, dynamic>;
            map.forEach((key, value) {
              students.add(UserModel.fromMap(Map<String, dynamic>.from(value)));
            });
          }
          return students;
        });
  }

  // Approve student
  Future<void> approveStudent(String studentId) async {
    await _dbRef.child('users').child(studentId).update({'isActive': true});
  }

  // Reject/Remove student
  Future<void> removeStudent(String studentId) async {
    await _dbRef.child('users').child(studentId).update({
      'teacherId': null,
      'isActive': false,
    });
  }

  // Create Exam
  Future<void> createExam(ExamModel exam) async {
    await _dbRef.child('exams').child(exam.id).set(exam.toMap());
  }

  // Get Exams for Teacher
  Stream<List<ExamModel>> getExamsForTeacher(String teacherId) {
    return _dbRef
        .child('exams')
        .orderByChild('teacherId')
        .equalTo(teacherId)
        .onValue
        .map((event) {
          final List<ExamModel> exams = [];
          if (event.snapshot.value != null) {
            final Map<dynamic, dynamic> map =
                event.snapshot.value as Map<dynamic, dynamic>;
            map.forEach((key, value) {
              exams.add(ExamModel.fromMap(Map<String, dynamic>.from(value)));
            });
          }
          return exams;
        });
  }

  // Submit Exam Result
  Future<void> submitExamResult(ExamResultModel result) async {
    await _dbRef.child('exam_results').child(result.id).set(result.toMap());
  }

  // Get Results for Student
  Stream<List<ExamResultModel>> getStudentResults(String studentId) {
    return _dbRef
        .child('exam_results')
        .orderByChild('studentId')
        .equalTo(studentId)
        .onValue
        .map((event) {
          final List<ExamResultModel> results = [];
          if (event.snapshot.value != null) {
            final Map<dynamic, dynamic> map =
                event.snapshot.value as Map<dynamic, dynamic>;
            map.forEach((key, value) {
              results.add(
                ExamResultModel.fromMap(Map<String, dynamic>.from(value)),
              );
            });
          }
          return results;
        });
  }

  // Record Payment
  Future<void> recordPayment(PaymentModel payment) async {
    await _dbRef.child('payments').child(payment.id).set(payment.toMap());
  }

  // Record Payment for Teacher (Helper)
  Future<void> recordPaymentForTeacher(
    String teacherId,
    PaymentModel payment,
  ) async {
    await _dbRef
        .child('payments')
        .child(teacherId)
        .child(payment.id)
        .set(payment.toMap());
  }

  // Get Payments for Teacher
  Stream<List<PaymentModel>> getPaymentsForTeacher(String teacherId) {
    return _dbRef.child('payments').child(teacherId).onValue.map((event) {
      final List<PaymentModel> payments = [];
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> map =
            event.snapshot.value as Map<dynamic, dynamic>;
        map.forEach((key, value) {
          payments.add(PaymentModel.fromMap(Map<String, dynamic>.from(value)));
        });
      }
      return payments;
    });
  }

  // Record Attendance
  Future<void> recordAttendance(
    String teacherId,
    AttendanceModel attendance,
  ) async {
    await _dbRef
        .child('attendance')
        .child(teacherId)
        .child(attendance.id)
        .set(attendance.toMap());
  }

  // Get Attendance for Teacher
  Stream<List<AttendanceModel>> getAttendanceForTeacher(String teacherId) {
    return _dbRef.child('attendance').child(teacherId).onValue.map((event) {
      final List<AttendanceModel> attendanceList = [];
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> map =
            event.snapshot.value as Map<dynamic, dynamic>;
        map.forEach((key, value) {
          attendanceList.add(
            AttendanceModel.fromMap(Map<String, dynamic>.from(value)),
          );
        });
      }
      return attendanceList;
    });
  }
}

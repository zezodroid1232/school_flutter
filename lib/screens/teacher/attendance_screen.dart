import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../models/user_model.dart';
import '../../models/attendance_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dataService = Provider.of<DataService>(context, listen: false);
    final teacherId = authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AttendanceModel>>(
              stream: dataService.getAttendanceForTeacher(teacherId),
              builder: (context, attendanceSnapshot) {
                final allAttendance = attendanceSnapshot.data ?? [];

                // Filter attendance for selected date
                final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
                final todaysAttendance = allAttendance.where((a) {
                  final aDate = DateTime.fromMillisecondsSinceEpoch(a.date);
                  return DateFormat('yyyy-MM-dd').format(aDate) == dateStr;
                }).toList();

                return StreamBuilder<List<UserModel>>(
                  stream: dataService.getStudentsForTeacher(teacherId),
                  builder: (context, studentSnapshot) {
                    if (!studentSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final students = studentSnapshot.data!
                        .where((s) => s.isActive)
                        .toList();

                    if (students.isEmpty) {
                      return const Center(child: Text('No active students.'));
                    }

                    return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        final attendanceRecord = todaysAttendance.firstWhere(
                          (a) => a.studentId == student.uid,
                          orElse: () => AttendanceModel(
                            id: '',
                            studentId: student.uid,
                            studentName: student.name,
                            date: 0,
                            isPresent: false,
                          ),
                        );

                        final isMarked = attendanceRecord.id.isNotEmpty;
                        final isPresent = attendanceRecord.isPresent;

                        return Card(
                          child: ListTile(
                            title: Text(student.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.check_circle,
                                    color: isMarked && isPresent
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  onPressed: () => _markAttendance(
                                    context,
                                    dataService,
                                    teacherId,
                                    student,
                                    true,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: isMarked && !isPresent
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  onPressed: () => _markAttendance(
                                    context,
                                    dataService,
                                    teacherId,
                                    student,
                                    false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markAttendance(
    BuildContext context,
    DataService dataService,
    String teacherId,
    UserModel student,
    bool isPresent,
  ) async {
    // Generate a consistent ID for the day-student combo to overwrite if exists
    // Or just use a new ID and let the backend handle it?
    // Better to query if exists, but for simplicity, we'll just create a new one with a unique ID based on date and student.
    // Actually, to allow updating, we should probably construct the ID.
    final dateStr = DateFormat('yyyyMMdd').format(_selectedDate);
    final id = '${dateStr}_${student.uid}';

    final attendance = AttendanceModel(
      id: id,
      studentId: student.uid,
      studentName: student.name,
      date: _selectedDate.millisecondsSinceEpoch,
      isPresent: isPresent,
    );

    await dataService.recordAttendance(teacherId, attendance);
  }
}

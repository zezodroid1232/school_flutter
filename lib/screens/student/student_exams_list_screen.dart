import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../models/exam_model.dart';
import '../../models/exam_result_model.dart';
import 'take_exam_screen.dart';

class StudentExamsListScreen extends StatelessWidget {
  const StudentExamsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dataService = Provider.of<DataService>(context, listen: false);
    final user = authService.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('Exams')),
      body: StreamBuilder<List<ExamModel>>(
        stream: dataService.getExamsForTeacher(user.teacherId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exams available.'));
          }

          final exams = snapshot.data!;

          return StreamBuilder<List<ExamResultModel>>(
            stream: dataService.getStudentResults(user.uid),
            builder: (context, resultSnapshot) {
              final results = resultSnapshot.data ?? [];

              return ListView.builder(
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final exam = exams[index];
                  final result = results.firstWhere(
                    (r) => r.examId == exam.id,
                    orElse: () => ExamResultModel(
                      id: '',
                      examId: '',
                      studentId: '',
                      studentName: '',
                      score: -1,
                      totalScore: 0,
                      answers: {},
                      timestamp: 0,
                    ),
                  );

                  final isTaken = result.id.isNotEmpty;

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(exam.title),
                      subtitle: Text(
                        isTaken
                            ? 'Score: ${result.score}/${result.totalScore}'
                            : '${exam.questions.length} Questions',
                      ),
                      trailing: isTaken
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TakeExamScreen(exam: exam),
                                  ),
                                );
                              },
                              child: const Text('Start'),
                            ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

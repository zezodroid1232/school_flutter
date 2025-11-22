import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../models/exam_model.dart';
import 'create_exam_screen.dart';

class ExamsListScreen extends StatelessWidget {
  const ExamsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dataService = Provider.of<DataService>(context, listen: false);
    final teacherId = authService.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<List<ExamModel>>(
        stream: dataService.getExamsForTeacher(teacherId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exams created yet.'));
          }

          final exams = snapshot.data!;

          return ListView.builder(
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(exam.title),
                  subtitle: Text('${exam.questions.length} Questions'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // View results or details
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateExamScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

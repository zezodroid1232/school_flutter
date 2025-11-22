import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../models/exam_model.dart';
import '../../models/exam_result_model.dart';

class TakeExamScreen extends StatefulWidget {
  final ExamModel exam;

  const TakeExamScreen({super.key, required this.exam});

  @override
  State<TakeExamScreen> createState() => _TakeExamScreenState();
}

class _TakeExamScreenState extends State<TakeExamScreen> {
  final Map<String, dynamic> _answers = {}; // Question Index -> Answer

  void _submitExam() async {
    // Check if all questions answered
    if (_answers.length < widget.exam.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final dataService = Provider.of<DataService>(context, listen: false);
    final user = authService.currentUser!;

    // Simple auto-grading for multiple choice
    int score = 0;
    for (int i = 0; i < widget.exam.questions.length; i++) {
      final q = widget.exam.questions[i];
      if (q.type == 'multiple_choice' && q.correctAnswer != null) {
        if (_answers[i.toString()] == q.correctAnswer) {
          score++;
        }
      }
      // Text questions need manual grading, score 0 for now
    }

    final result = ExamResultModel(
      id: const Uuid().v4(),
      examId: widget.exam.id,
      studentId: user.uid,
      studentName: user.name,
      score: score, // Preliminary score
      totalScore: widget.exam.questions.length,
      answers: _answers,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await dataService.submitExamResult(result);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exam.title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.exam.questions.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.exam.questions.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                onPressed: _submitExam,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Submit Exam',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }

          final q = widget.exam.questions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q${index + 1}: ${q.question}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (q.type == 'multiple_choice' && q.options != null)
                    ...q.options!.map(
                      (option) => RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: _answers[index.toString()],
                        onChanged: (val) {
                          setState(() {
                            _answers[index.toString()] = val;
                          });
                        },
                      ),
                    )
                  else
                    TextField(
                      onChanged: (val) {
                        _answers[index.toString()] = val;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type your answer here',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

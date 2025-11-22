import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../models/exam_model.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({super.key});

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final List<QuestionModel> _questions = [];

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => _AddQuestionDialog(
        onAdd: (question) {
          setState(() {
            _questions.add(question);
          });
        },
      ),
    );
  }

  Future<void> _saveExam() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one question')),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final dataService = Provider.of<DataService>(context, listen: false);

    final exam = ExamModel(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      teacherId: authService.currentUser!.uid,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      questions: _questions,
    );

    await dataService.createExam(exam);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Exam')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Exam Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final q = _questions[index];
                  return ListTile(
                    title: Text('Q${index + 1}: ${q.question}'),
                    subtitle: Text('Type: ${q.type}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _questions.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addQuestion,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Question'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveExam,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Exam'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddQuestionDialog extends StatefulWidget {
  final Function(QuestionModel) onAdd;

  const _AddQuestionDialog({required this.onAdd});

  @override
  State<_AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<_AddQuestionDialog> {
  final TextEditingController _questionController = TextEditingController();
  String _type = 'text'; // 'text' or 'multiple_choice'
  final List<TextEditingController> _optionsControllers = [];
  int? _correctOptionIndex;

  void _addOption() {
    setState(() {
      _optionsControllers.add(TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Question'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Question Text'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _type,
              items: const [
                DropdownMenuItem(value: 'text', child: Text('Text Answer')),
                DropdownMenuItem(
                  value: 'multiple_choice',
                  child: Text('Multiple Choice'),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  _type = val!;
                  if (_type == 'multiple_choice' &&
                      _optionsControllers.isEmpty) {
                    _addOption();
                    _addOption();
                  }
                });
              },
            ),
            if (_type == 'multiple_choice') ...[
              const SizedBox(height: 10),
              ...List.generate(_optionsControllers.length, (index) {
                return Row(
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: _correctOptionIndex,
                      onChanged: (val) =>
                          setState(() => _correctOptionIndex = val),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _optionsControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Option ${index + 1}',
                        ),
                      ),
                    ),
                  ],
                );
              }),
              TextButton(
                onPressed: _addOption,
                child: const Text('Add Option'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_questionController.text.isEmpty) return;

            List<String>? options;
            String? correctAnswer;

            if (_type == 'multiple_choice') {
              options = _optionsControllers.map((c) => c.text).toList();
              if (_correctOptionIndex != null) {
                correctAnswer = options[_correctOptionIndex!];
              }
            }

            widget.onAdd(
              QuestionModel(
                question: _questionController.text,
                type: _type,
                options: options,
                correctAnswer: correctAnswer,
              ),
            );
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

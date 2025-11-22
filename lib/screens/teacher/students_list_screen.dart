import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../models/user_model.dart';
import '../chat_screen.dart';

class StudentsListScreen extends StatelessWidget {
  const StudentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dataService = Provider.of<DataService>(context, listen: false);
    final teacherId = authService.currentUser!.uid;

    return StreamBuilder<List<UserModel>>(
      stream: dataService.getStudentsForTeacher(teacherId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No students yet.'));
        }

        final allStudents = snapshot.data!;
        final requests = allStudents.where((s) => !s.isActive).toList();
        final activeStudents = allStudents.where((s) => s.isActive).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (requests.isNotEmpty) ...[
              const Text(
                'Join Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 10),
              ...requests.map(
                (student) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_add, color: Colors.orange),
                    title: Text(student.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () =>
                              dataService.approveStudent(student.uid),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () =>
                              dataService.removeStudent(student.uid),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 30),
            ],
            const Text(
              'My Students',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            ...activeStudents.map(
              (student) => Card(
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(student.name),
                  subtitle: const Text('Tap to chat'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () =>
                        _confirmDelete(context, dataService, student),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          studentId: student.uid,
                          otherUserName: student.name,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    DataService dataService,
    UserModel student,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text('Are you sure you want to remove ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              dataService.removeStudent(student.uid);
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

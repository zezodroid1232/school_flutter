import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../models/user_model.dart';
import '../chat_screen.dart';
import 'student_exams_list_screen.dart';
import '../profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user.teacherId == null) {
      return _buildTeacherSelection(context);
    }

    if (!user.isActive) {
      return _buildWaitingScreen(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome Student! You are active.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      studentId: user.uid,
                      otherUserName: 'Teacher',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat),
              label: const Text('Chat with Teacher'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudentExamsListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.assignment),
              label: const Text('View Exams'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              icon: const Icon(Icons.person),
              label: const Text('My Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherSelection(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Teacher'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: dataService.getTeachers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No teachers found.'));
          }

          final teachers = snapshot.data!;

          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: teacher.photoUrl != null
                        ? NetworkImage(teacher.photoUrl!)
                        : null,
                    child: teacher.photoUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(teacher.name),
                  subtitle: Text(teacher.email),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await dataService.requestJoinTeacher(
                        authService.currentUser!.uid,
                        teacher.uid,
                      );
                      // Refresh user data to update UI
                      await authService.fetchUserData(
                        authService.currentUser!.uid,
                      );
                    },
                    child: const Text('Join'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWaitingScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Class'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Provider.of<AuthService>(context, listen: false).signOut(),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pending_actions, size: 64, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              'Waiting for Teacher Approval',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Please wait for your teacher to accept your request.'),
          ],
        ),
      ),
    );
  }
}

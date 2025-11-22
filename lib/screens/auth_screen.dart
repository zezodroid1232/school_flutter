import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();

  Future<void> _handleTeacherLogin() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final userCredential = await authService.signInWithGoogle();

    if (userCredential != null && userCredential.user != null) {
      final user = userCredential.user!;
      final exists = await authService.userExists(user.uid);

      if (!exists) {
        // Create new teacher account
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'Teacher',
          role: 'teacher',
          photoUrl: user.photoURL,
        );
        await authService.registerUser(newUser);
      } else {
        await authService.fetchUserData(user.uid);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleStudentLogin() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      // Sign in anonymously for student
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final user = userCredential.user!;

      // Create new student account
      final newUser = UserModel(
        uid: user.uid,
        email: '', // No email for students
        name: _nameController.text.trim(),
        role: 'student',
        isActive: false, // Needs teacher approval
      );

      await authService.registerUser(newUser);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.blue.shade500],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school, size: 80, color: Colors.blue),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Choose your role to continue',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else ...[
                      _buildTeacherButton(),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      _buildStudentSection(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _handleTeacherLogin,
        icon: const Icon(Icons.person, color: Colors.white),
        label: const Text(
          'Continue as Teacher',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentSection() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Student Name',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _handleStudentLogin,
            icon: const Icon(Icons.school_outlined),
            label: const Text(
              'Continue as Student',
              style: TextStyle(fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: Colors.blue.shade700),
            ),
          ),
        ),
      ],
    );
  }
}

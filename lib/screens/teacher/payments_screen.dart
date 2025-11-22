import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/data_service.dart';
import '../../models/user_model.dart';
import '../../models/payment_model.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dataService = Provider.of<DataService>(context, listen: false);
    final teacherId = authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: StreamBuilder<List<PaymentModel>>(
        stream: dataService.getPaymentsForTeacher(teacherId),
        builder: (context, paymentSnapshot) {
          if (paymentSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final payments = paymentSnapshot.data ?? [];

          return StreamBuilder<List<UserModel>>(
            stream: dataService.getStudentsForTeacher(teacherId),
            builder: (context, studentSnapshot) {
              if (!studentSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final students = studentSnapshot.data!
                  .where((s) => s.isActive)
                  .toList();

              return ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final studentPayments = payments
                      .where((p) => p.studentId == student.uid)
                      .toList();

                  // Sort payments by date descending
                  studentPayments.sort((a, b) => b.date.compareTo(a.date));

                  return ExpansionTile(
                    title: Text(student.name),
                    subtitle: Text('Total Payments: ${studentPayments.length}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () =>
                                  _showAddPaymentDialog(context, student),
                              child: const Text('Add Payment'),
                            ),
                            const SizedBox(height: 10),
                            if (studentPayments.isEmpty)
                              const Text('No payments recorded.')
                            else
                              ...studentPayments.map(
                                (p) => ListTile(
                                  title: Text('${p.amount} - ${p.month}'),
                                  subtitle: Text(
                                    DateFormat('yyyy-MM-dd').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                        p.date,
                                      ),
                                    ),
                                  ),
                                  trailing: p.note != null
                                      ? Text(p.note!)
                                      : null,
                                ),
                              ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showAddPaymentDialog(BuildContext context, UserModel student) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Payment for ${student.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note (Optional)'),
            ),
            const SizedBox(height: 10),
            Text('Month: $selectedMonth'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (amountController.text.isEmpty) return;

              final payment = PaymentModel(
                id: const Uuid().v4(),
                studentId: student.uid,
                studentName: student.name,
                amount: double.tryParse(amountController.text) ?? 0.0,
                date: DateTime.now().millisecondsSinceEpoch,
                month: selectedMonth,
                note: noteController.text.isEmpty ? null : noteController.text,
              );

              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              final dataService = Provider.of<DataService>(
                context,
                listen: false,
              );

              await dataService.recordPaymentForTeacher(
                authService.currentUser!.uid,
                payment,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

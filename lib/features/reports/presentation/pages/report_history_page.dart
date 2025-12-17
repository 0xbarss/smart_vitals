import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';

class ReportHistoryPage extends StatelessWidget {
  const ReportHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: Text("Please log in.")));
    }

    final userId = authState.user.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Data History"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('health_reports')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("No history found", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp).toDate();
              final type = data['type'] ?? 'unknown';
              final records = (data['data'] as Map<String, dynamic>?)?.length ?? 0;
              final isEnabizImport = type == 'enabiz_import';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isEnabizImport
                        ? const Color(0xFFE11D48).withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    child: Icon(
                      isEnabizImport ? Icons.cloud_download : Icons.edit,
                      color: isEnabizImport ? const Color(0xFFE11D48) : Colors.blue,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    DateFormat('dd MMM yyyy').format(date),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    isEnabizImport
                        ? "E-Nabız Import • $records records"
                        : "Manual Entry • $records records",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => _confirmDelete(context, doc.reference),
                  ),
                  onTap: () {
                    _showDetailDialog(context, date, data['data']);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, DocumentReference ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Record?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.delete();
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context, DateTime date, Map<String, dynamic>? data) {
    if (data == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Details: ${DateFormat('dd MMM yyyy').format(date)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  String key = data.keys.elementAt(index);
                  var value = data[key];

                  String displayValue = "";
                  String displayUnit = "";

                  if (value is Map) {
                    displayValue = value['result'] ?? "";
                    displayUnit = value['unit'] ?? "";
                  } else {
                    displayValue = value.toString();
                  }

                  return ListTile(
                    title: Text(key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: Text(
                      "$displayValue $displayUnit",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    dense: true,
                  );
                },
              ),
            ),
            const Divider(height: 1),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}
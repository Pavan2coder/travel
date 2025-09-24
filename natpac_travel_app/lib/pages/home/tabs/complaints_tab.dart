import 'package:flutter/material.dart';
import '../../../models/complaint.dart';
import '../../../services/storage_service.dart';
import '../../complaints/new_complaint_page.dart';

class ComplaintsTab extends StatefulWidget {
  const ComplaintsTab({super.key});

  @override
  State<ComplaintsTab> createState() => _ComplaintsTabState();
}

class _ComplaintsTabState extends State<ComplaintsTab> {
  late Future<List<Complaint>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = StorageService.instance.loadComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder(
            future: _future,
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final items = snap.data!;
              if (items.isEmpty) return const Center(child: Text('No complaints yet.'));
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final c = items[i];
                  return ListTile(
                    leading: Icon(Icons.flag, color: c.priority == 'high' ? Colors.red : c.priority == 'medium' ? Colors.orange : Colors.green),
                    title: Text('${c.category} • ${c.priority}'),
                    subtitle: Text(c.details),
                    trailing: c.linkedTripId != null ? const Icon(Icons.link) : null,
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewComplaintPage()));
                setState(_reload);
              },
              icon: const Icon(Icons.add),
              label: const Text('New complaint'),
            ),
          ),
        ),
      ],
    );
  }
}


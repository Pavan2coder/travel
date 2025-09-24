import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/complaint.dart';
import '../../services/storage_service.dart';
import '../../state/app_state.dart';

class NewComplaintPage extends StatefulWidget {
  const NewComplaintPage({super.key});

  @override
  State<NewComplaintPage> createState() => _NewComplaintPageState();
}

class _NewComplaintPageState extends State<NewComplaintPage> {
  final _categories = ['road block', 'traffic jam', 'bus delay', 'accident', 'other'];
  final _priorities = ['high', 'medium', 'low'];
  String _category = 'road block';
  String _priority = 'medium';
  String _details = '';
  bool _linkToTrip = false;

  Future<void> _submit() async {
    final tripId = _linkToTrip ? context.read<AppState>().activeTrip?.id : null;
    final c = Complaint(category: _category, details: _details, priority: _priority, linkedTripId: tripId);
    await StorageService.instance.saveComplaint(c);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final hasActive = context.watch<AppState>().activeTrip != null;
    return Scaffold(
      appBar: AppBar(title: const Text('New Complaint')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _category,
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _priority,
            items: _priorities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (v) => setState(() => _priority = v ?? _priority),
            decoration: const InputDecoration(labelText: 'Priority'),
          ),
          const SizedBox(height: 8),
          TextFormField(
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Details', border: OutlineInputBorder()),
            onChanged: (v) => _details = v,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _linkToTrip,
            onChanged: (v) => setState(() => _linkToTrip = v ?? false),
            title: const Text('Is it related to this trip?'),
            subtitle: Text(hasActive ? 'Linked to active trip' : 'No active trip right now'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: _submit, child: const Text('Submit complaint'))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
            ],
          ),
        ],
      ),
    );
  }
}


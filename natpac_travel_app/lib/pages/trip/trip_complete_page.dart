import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../models/trip.dart';
import '../../services/storage_service.dart';
import '../../state/app_state.dart';

class TripCompletePage extends StatefulWidget {
  final Trip trip;
  const TripCompletePage({super.key, required this.trip});

  @override
  State<TripCompletePage> createState() => _TripCompletePageState();
}

class _TripCompletePageState extends State<TripCompletePage> {
  final List<Segment> _segments = [];
  final List<Companion> _companions = [];
  bool _hasCompanions = false;

  @override
  void initState() {
    super.initState();
    _segments.add(Segment(mode: TravelMode.walk, purpose: TripPurpose.personal));
  }

  void _addSegment() {
    setState(() {
      _segments.add(Segment(mode: TravelMode.walk, purpose: TripPurpose.personal));
    });
  }

  void _addCompanion() {
    setState(() {
      _companions.add(Companion(name: '', age: 0, relation: 'friend'));
    });
  }

  Future<void> _save() async {
    widget.trip.segments = _segments;
    if (_hasCompanions) widget.trip.companions = _companions;
    await StorageService.instance.saveTrip(widget.trip);
    if (mounted) {
      context.read<AppState>().addStars(1);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final modes = TravelMode.values;
    final purposes = TripPurpose.values;
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Trip Details')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text('Stops: ${widget.trip.stops.length} • Distance ~ ${_estimateDistanceKm(widget.trip).toStringAsFixed(2)} km'),
          const SizedBox(height: 8),
          ..._segments.asMap().entries.map((e) {
            final i = e.key;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Segment ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TravelMode>(
                      value: _segments[i].mode,
                      items: modes.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                      onChanged: (v) => setState(() => _segments[i].mode = v!),
                      decoration: const InputDecoration(labelText: 'Transport mode'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TripPurpose>(
                      value: _segments[i].purpose,
                      items: purposes.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                      onChanged: (v) => setState(() => _segments[i].purpose = v!),
                      decoration: const InputDecoration(labelText: 'Purpose'),
                    ),
                  ],
                ),
              ),
            );
          }),
          TextButton.icon(onPressed: _addSegment, icon: const Icon(Icons.add), label: const Text('Add another segment')),
          const Divider(),
          CheckboxListTile(
            value: _hasCompanions,
            onChanged: (v) => setState(() => _hasCompanions = v ?? false),
            title: const Text('I had travel companions'),
          ),
          if (_hasCompanions) ...[
            ..._companions.asMap().entries.map((e) {
              final i = e.key;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _companions[i].name,
                        decoration: const InputDecoration(labelText: 'Name'),
                        onChanged: (v) => _companions[i].name = v,
                      ),
                      TextFormField(
                        initialValue: _companions[i].age == 0 ? '' : _companions[i].age.toString(),
                        decoration: const InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _companions[i].age = int.tryParse(v) ?? 0,
                      ),
                      TextFormField(
                        initialValue: _companions[i].relation,
                        decoration: const InputDecoration(labelText: 'Relation (child, parent, friend...)'),
                        onChanged: (v) => _companions[i].relation = v,
                      ),
                    ],
                  ),
                ),
              );
            }),
            TextButton.icon(onPressed: _addCompanion, icon: const Icon(Icons.group_add), label: const Text('Add companion')),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: _save, child: const Text('Save trip details'))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Skip'))),
            ],
          ),
        ],
      ),
    );
  }

  double _estimateDistanceKm(Trip t) {
    double sum = 0;
    final d = const Distance();
    for (int i = 1; i < t.path.length; i++) {
      sum += d(t.path[i - 1], t.path[i]);
    }
    return sum / 1000.0;
  }
}


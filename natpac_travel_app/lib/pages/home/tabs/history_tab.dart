import 'package:flutter/material.dart';
import '../../../services/storage_service.dart';
import '../../../models/trip.dart';
import 'package:intl/intl.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});
  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  late Future<List<Trip>> _future;

  @override
  void initState() {
    super.initState();
    _future = StorageService.instance.loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yMMMd HH:mm');
    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final trips = snap.data!;
        if (trips.isEmpty) return const Center(child: Text('No trips saved yet.'));
        return ListView.builder(
          itemCount: trips.length,
          itemBuilder: (_, i) {
            final t = trips[i];
            return ListTile(
              title: Text('Trip #${t.tripNumber} • Stops: ${t.stops.length}'),
              subtitle: Text('${df.format(t.startTime)} → ${t.endTime != null ? df.format(t.endTime!) : 'ongoing'}'),
            );
          },
        );
      },
    );
  }
}


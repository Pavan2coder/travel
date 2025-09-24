import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../models/trip.dart';
import '../../../services/location_service.dart';
import '../../../services/trip_detector.dart';
import '../../../state/app_state.dart';
import '../../trip/trip_complete_page.dart';
import 'package:geolocator/geolocator.dart';

class TrackerTab extends StatefulWidget {
  const TrackerTab({super.key});

  @override
  State<TrackerTab> createState() => _TrackerTabState();
}

class _TrackerTabState extends State<TrackerTab> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _posSub;
  LatLng? _current;
  double _distanceKm = 0;
  DateTime? _start;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAuto();
  }

  Future<void> _initAuto() async {
    final app = context.read<AppState>();
    if (app.autoStartEnabled) {
      _startTracking();
    }
  }

  Future<void> _startTracking() async {
    final loc = context.read<LocationService>();
    final ok = await loc.ensurePermissions();
    if (!ok) return;

    final stream = loc.startLocationStream(distanceFilterMeters: 40);
    _posSub?.cancel();

    final detector = context.read<TripDetector>();
    detector.attach(
      stream,
      onTripStart: (trip) {
        context.read<AppState>().setActiveTrip(trip);
        setState(() {
          _start = DateTime.now();
          _elapsed = Duration.zero;
          _distanceKm = 0;
        });
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() {
            _elapsed = DateTime.now().difference(_start!);
          });
        });
      },
      onTripUpdate: (trip) {
        if (trip.path.length >= 2) {
          final d = const Distance();
          double sum = 0;
          for (int i = 1; i < trip.path.length; i++) {
            sum += d(trip.path[i - 1], trip.path[i]);
          }
          setState(() {
            _distanceKm = sum / 1000.0;
            _current = trip.path.last;
          });
          if (_current != null) {
            _mapController.move(_current!, _mapController.camera.zoom);
          }
        }
      },
      onTripEnd: (trip) {
        _timer?.cancel();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripCompletePage(trip: trip)));
        context.read<AppState>().setActiveTrip(null);
      },
    );

    _posSub = stream.listen((pos) {
      setState(() => _current = LatLng(pos.latitude, pos.longitude));
      if (_current != null) {
        _mapController.move(_current!, 16);
      }
    });
  }

  Future<void> _stopTracking() async {
    await _posSub?.cancel();
    _posSub = null;
    _timer?.cancel();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = context.watch<AppState>().activeTrip;
    final stops = trip?.stops ?? [];
    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _current ?? const LatLng(10.0, 76.0),
              initialZoom: 15,
            ),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'org.natpac.travel'),
              if (trip != null && trip.path.isNotEmpty)
                PolylineLayer(polylines: [Polyline(points: trip.path, color: Colors.indigo, strokeWidth: 5)]),
              if (_current != null)
                MarkerLayer(markers: [Marker(point: _current!, width: 40, height: 40, child: const Icon(Icons.my_location, color: Colors.blue))]),
              if (stops.isNotEmpty)
                MarkerLayer(
                  markers: stops.map((s) => Marker(point: s.location, width: 36, height: 36, child: const Icon(Icons.stop_circle, color: Colors.red))).toList(),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Distance: ${_distanceKm.toStringAsFixed(2)} km'),
                Text('Time: ${_elapsed.inMinutes.toString().padLeft(2, '0')}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}'),
              ]),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: ElevatedButton.icon(onPressed: _startTracking, icon: const Icon(Icons.play_arrow), label: const Text('Start'))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(onPressed: _stopTracking, icon: const Icon(Icons.stop), label: const Text('Stop'))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}


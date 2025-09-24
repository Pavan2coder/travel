import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/trip.dart';

class TripDetector {
  static const double _stopRadiusMeters = 60;
  static const Duration _stopDwell = Duration(minutes: 20);
  static const double _returnHomeRadiusMeters = 100;

  final Distance _distance = const Distance();

  StreamSubscription<Position>? _sub;
  LatLng? _startPoint;
  DateTime? _startTime;

  StopPoint? _candidateStop;
  Trip? _current;

  void attach(Stream<Position> positionStream, {required void Function(Trip) onTripStart, required void Function(Trip) onTripEnd, required void Function(Trip) onTripUpdate}) {
    _sub?.cancel();
    _sub = positionStream.listen((pos) {
      final p = LatLng(pos.latitude, pos.longitude);
      final now = DateTime.now();

      if (_current == null) {
        _current = Trip(tripNumber: 0, startTime: now, startLocation: p);
        _startPoint = p;
        _startTime = now;
        onTripStart(_current!);
      }

      _current!.path.add(p);

      if (_candidateStop == null) {
        _candidateStop = StopPoint(startTime: now, location: p);
      } else {
        final dist = _distance(p, _candidateStop!.location);
        if (dist <= _stopRadiusMeters) {
          final dwell = now.difference(_candidateStop!.startTime);
          if (dwell >= _stopDwell && (_current!.stops.isEmpty || _current!.stops.last != _candidateStop)) {
            _candidateStop!.endTime = now;
            _current!.stops.add(_candidateStop!);
            _candidateStop = null;
          }
        } else {
          _candidateStop = StopPoint(startTime: now, location: p);
        }
      }

      if (_startPoint != null && _current!.stops.isNotEmpty) {
        final backDist = _distance(p, _startPoint!);
        if (backDist <= _returnHomeRadiusMeters) {
          _current!.endTime = now;
          _current!.endLocation = p;
          onTripUpdate(_current!);
          onTripEnd(_current!);
          _reset();
          return;
        }
      }

      onTripUpdate(_current!);
    });
  }

  void _reset() {
    _sub?.cancel();
    _sub = null;
    _current = null;
    _candidateStop = null;
    _startPoint = null;
    _startTime = null;
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}


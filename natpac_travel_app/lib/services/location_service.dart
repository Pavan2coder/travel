import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  StreamSubscription<Position>? _subscription;

  Future<bool> ensurePermissions() async {
    final status = await Permission.location.request();
    if (status.isDenied) return false;
    if (await Permission.locationAlways.isDenied) {
      await Permission.locationAlways.request();
    }
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    return await Geolocator.isLocationServiceEnabled();
  }

  Stream<Position> startLocationStream({double distanceFilterMeters = 50}) {
    _subscription?.cancel();
    final stream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters.toInt(),
      ),
    );
    return stream;
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}


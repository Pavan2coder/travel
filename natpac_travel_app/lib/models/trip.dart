import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

enum TravelMode { walk, bike, car, bus, train, auto, taxi, other }
enum TripPurpose { work, education, shopping, personal, leisure, other }
enum ComplaintPriority { high, medium, low }

class Companion {
  String name;
  int age;
  String relation;

  Companion({required this.name, required this.age, required this.relation});
}

class Segment {
  String id;
  TravelMode mode;
  TripPurpose purpose;
  double distanceKm;

  Segment({String? id, required this.mode, required this.purpose, this.distanceKm = 0})
      : id = id ?? const Uuid().v4();
}

class StopPoint {
  DateTime startTime;
  DateTime? endTime;
  LatLng location;

  StopPoint({required this.startTime, required this.location, this.endTime});
}

class Trip {
  String id;
  int tripNumber;
  DateTime startTime;
  DateTime? endTime;
  LatLng startLocation;
  LatLng? endLocation;
  List<LatLng> path;
  List<StopPoint> stops;
  List<Segment> segments;
  List<Companion> companions;

  Trip({String? id, required this.tripNumber, required this.startTime, required this.startLocation, this.endTime, this.endLocation, List<LatLng>? path, List<StopPoint>? stops, List<Segment>? segments, List<Companion>? companions})
      : id = id ?? const Uuid().v4(),
        path = path ?? <LatLng>[],
        stops = stops ?? <StopPoint>[],
        segments = segments ?? <Segment>[],
        companions = companions ?? <Companion>[];
}


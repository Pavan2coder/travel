import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/trip.dart';
import '../models/complaint.dart';
import 'package:latlong2/latlong.dart';

class StorageService {
  StorageService._();
  static final instance = StorageService._();

  Database? _db;

  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'natpac.db');
    _db = await openDatabase(dbPath, version: 1, onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE trips(
          id TEXT PRIMARY KEY,
          tripNumber INTEGER,
          startTime TEXT,
          endTime TEXT,
          startLat REAL, startLng REAL,
          endLat REAL, endLng REAL,
          path TEXT,
          stops TEXT,
          segments TEXT,
          companions TEXT
        );
      ''');
      await db.execute('''
        CREATE TABLE complaints(
          id TEXT PRIMARY KEY,
          createdAt TEXT,
          category TEXT,
          details TEXT,
          priority TEXT,
          linkedTripId TEXT
        );
      ''');
    });
  }

  Future<void> saveTrip(Trip t) async {
    await _db!.insert('trips', {
      'id': t.id,
      'tripNumber': t.tripNumber,
      'startTime': t.startTime.toIso8601String(),
      'endTime': t.endTime?.toIso8601String(),
      'startLat': t.startLocation.latitude,
      'startLng': t.startLocation.longitude,
      'endLat': t.endLocation?.latitude,
      'endLng': t.endLocation?.longitude,
      'path': _encodePath(t.path),
      'stops': _encodeStops(t.stops),
      'segments': _encodeSegments(t.segments),
      'companions': _encodeCompanions(t.companions),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Trip>> loadTrips() async {
    final rows = await _db!.query('trips', orderBy: 'startTime DESC');
    return rows.map(_tripFromRow).toList();
  }

  Future<void> saveComplaint(Complaint c) async {
    await _db!.insert('complaints', {
      'id': c.id,
      'createdAt': c.createdAt.toIso8601String(),
      'category': c.category,
      'details': c.details,
      'priority': c.priority,
      'linkedTripId': c.linkedTripId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Complaint>> loadComplaints() async {
    final rows = await _db!.query('complaints', orderBy: 'createdAt DESC');
    return rows.map((r) => Complaint(
      id: r['id'] as String,
      category: r['category'] as String,
      details: r['details'] as String,
      priority: r['priority'] as String,
      linkedTripId: r['linkedTripId'] as String?,
      createdAt: DateTime.parse(r['createdAt'] as String),
    )).toList();
  }

  String _encodePath(List<LatLng> path) => path.map((p) => '${p.latitude},${p.longitude}').join(';');
  String _encodeStops(List<StopPoint> stops) => stops.map((s) => '${s.location.latitude},${s.location.longitude},${s.startTime.toIso8601String()},${s.endTime?.toIso8601String() ?? ''}').join(';');
  String _encodeSegments(List<Segment> segs) => segs.map((s) => '${s.id},${s.mode.name},${s.purpose.name},${s.distanceKm}').join(';');
  String _encodeCompanions(List<Companion> cs) => cs.map((c) => '${c.name},${c.age},${c.relation}').join(';');

  List<LatLng> _decodePath(String s) => s.isEmpty ? [] : s.split(';').map((e) {
    final parts = e.split(',');
    return LatLng(double.parse(parts[0]), double.parse(parts[1]));
  }).toList();

  List<StopPoint> _decodeStops(String s) => s.isEmpty ? [] : s.split(';').map((e) {
    final parts = e.split(',');
    return StopPoint(
      startTime: DateTime.parse(parts[2]),
      location: LatLng(double.parse(parts[0]), double.parse(parts[1])),
      endTime: parts[3].isEmpty ? null : DateTime.parse(parts[3]),
    );
  }).toList();

  List<Segment> _decodeSegments(String s) => s.isEmpty ? [] : s.split(';').map((e) {
    final parts = e.split(',');
    return Segment(
      id: parts[0],
      mode: TravelMode.values.byName(parts[1]),
      purpose: TripPurpose.values.byName(parts[2]),
      distanceKm: double.parse(parts[3]),
    );
  }).toList();

  Trip _tripFromRow(Map<String, Object?> r) {
    return Trip(
      id: r['id'] as String,
      tripNumber: r['tripNumber'] as int,
      startTime: DateTime.parse(r['startTime'] as String),
      endTime: (r['endTime'] as String?) != null && (r['endTime'] as String).isNotEmpty ? DateTime.parse(r['endTime'] as String) : null,
      startLocation: LatLng(r['startLat'] as double, r['startLng'] as double),
      endLocation: (r['endLat'] != null && r['endLng'] != null) ? LatLng(r['endLat'] as double, r['endLng'] as double) : null,
      path: _decodePath(r['path'] as String),
      stops: _decodeStops(r['stops'] as String),
      segments: _decodeSegments(r['segments'] as String),
    );
  }
}


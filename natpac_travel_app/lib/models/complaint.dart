import 'package:uuid/uuid.dart';

class Complaint {
  String id;
  DateTime createdAt;
  String category;
  String details;
  String priority;
  String? linkedTripId;

  Complaint({String? id, required this.category, required this.details, required this.priority, this.linkedTripId, DateTime? createdAt})
      : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}


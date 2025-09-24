import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences prefs;
  static const _starsKey = 'stars_total';
  static const _autoStartKey = 'auto_start_enabled';

  int _totalStars = 0;
  bool _autoStartEnabled = true;
  Trip? _activeTrip;

  AppState(this.prefs) {
    _totalStars = prefs.getInt(_starsKey) ?? 0;
    _autoStartEnabled = prefs.getBool(_autoStartKey) ?? true;
  }

  int get totalStars => _totalStars;
  bool get autoStartEnabled => _autoStartEnabled;
  Trip? get activeTrip => _activeTrip;

  void setActiveTrip(Trip? trip) {
    _activeTrip = trip;
    notifyListeners();
  }

  void addStars(int count) {
    _totalStars += count;
    prefs.setInt(_starsKey, _totalStars);
    notifyListeners();
  }

  void setAutoStart(bool value) {
    _autoStartEnabled = value;
    prefs.setBool(_autoStartKey, value);
    notifyListeners();
  }
}


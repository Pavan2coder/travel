# NATPAC Travel App

Flutter app with OpenStreetMap trip tracking, stop detection, trip details, stars, history, and complaints.

## Run

1. Install Flutter and Android Studio.
2. Open this folder in Android Studio: `/workspace/natpac_travel_app`.
3. In terminal: `flutter pub get`
4. Run on a device/emulator.
5. Grant location and notification permissions.

## Android permissions

`android/app/src/main/AndroidManifest.xml` includes INTERNET, LOCATION, BACKGROUND LOCATION, NOTIFICATIONS, and FOREGROUND_SERVICE.

## Notes
- Uses `flutter_map` for OSM tiles.
- Uses `geolocator` for location stream.
- Uses `sqflite` for local storage.
- Uses `flutter_local_notifications` for daily reminder.


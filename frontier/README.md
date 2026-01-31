# frontier

Smart parking / mobility UI demo built in Flutter with Mapbox.

## Quick start (Android)

1. Add your Mapbox token:
	- Update [lib/config/mapbox_config.dart](lib/config/mapbox_config.dart)
	- Update [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)

2. Install dependencies:

```powershell
flutter pub get
```

3. Run on emulator/device:

```powershell
flutter devices
flutter run -d emulator-5554
```

## Notes

- Typeface: the UI uses `SF Pro` in theme settings. For perfect fidelity, add your licensed SF Pro font files and configure `pubspec.yaml`.
- All data is local dummy data (no backend/auth/payments).

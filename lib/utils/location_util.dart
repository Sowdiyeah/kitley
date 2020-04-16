import 'package:geolocator/geolocator.dart';

Future<Position> getLocation() async {
  bool locationEnabled = await Geolocator().isLocationServiceEnabled();
  if (!locationEnabled) return null;

  Position position;
  try {
    position = await Geolocator().getLastKnownPosition();
    position = position ?? await Geolocator().getCurrentPosition();
  } catch (e) {
    print('Error: $e');
  }

  return position;
}

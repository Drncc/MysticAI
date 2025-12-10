import 'package:geolocator/geolocator.dart';

/// Structure to hold necessary context data.
class WeatherData {
  final String condition; // e.g., "Cloudy", "Stormy"
  final double temperatureCelsius;
  final double atmosphericPressureHpa; // Relevant for mystical interpretation

  const WeatherData({
    required this.condition,
    required this.temperatureCelsius,
    required this.atmosphericPressureHpa,
  });
}

/// Abstract service for gathering Physical Context data (Location & Weather).
abstract class LocationWeatherService {
  const LocationWeatherService();

  /// Requests location permissions and determines if the device can access location.
  Future<bool> requestLocationPermission();

  /// Gets the current device position.
  Future<Position> getCurrentPosition();

  /// Fetches current weather data based on coordinates (requires OpenWeatherMap API key integration).
  Future<WeatherData> fetchWeatherData({required double latitude, required double longitude});
}

// Provider definition will follow once implementation details are confirmed.
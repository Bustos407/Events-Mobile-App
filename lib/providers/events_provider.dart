import 'package:flutter/foundation.dart';
import '../data/mock_events.dart';
import '../models/event.dart';
import '../services/location_service.dart';

class EventWithDistance {
  final EventItem event;
  final double distanceKm;
  EventWithDistance(this.event, this.distanceKm);
}

/// Radius that separates "cerca de ti" from events that require travel.
const double kNearbyRadiusKm = 60;

/// How soon an event must start to trigger the "próximamente" notification.
const int kNotifyWithinDays = 3;

class EventsProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  double? _lat;
  double? _lng;
  bool _loadingLocation = true;

  bool get loadingLocation => _loadingLocation;
  double? get lat => _lat;
  double? get lng => _lng;

  Future<void> loadLocation() async {
    _loadingLocation = true;
    notifyListeners();
    final (lat, lng) = await _locationService.getCurrentLatLng();
    _lat = lat;
    _lng = lng;
    _loadingLocation = false;
    notifyListeners();
  }

  List<EventWithDistance> _withDistances(List<EventItem> events) {
    if (_lat == null || _lng == null) return [];
    return events
        .map((e) => EventWithDistance(
              e,
              _locationService.distanceKm(_lat!, _lng!, e.lat, e.lng),
            ))
        .toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  }

  List<EventWithDistance> nearbyEventsForInterests(List<String> interests) {
    final matching = kMockEvents.where((e) => interests.contains(e.category));
    return _withDistances(matching.toList())
        .where((ed) => ed.distanceKm <= kNearbyRadiusKm)
        .toList();
  }

  List<EventWithDistance> upcomingNotifications(List<String> interests) {
    final now = DateTime.now();
    return nearbyEventsForInterests(interests)
        .where((ed) => ed.event.dateTime.difference(now).inDays <= kNotifyWithinDays)
        .toList();
  }

  /// Events far from the user's current location, for "travel mode" search.
  List<EventWithDistance> farEventsForInterests(List<String> interests) {
    final matching = kMockEvents.where((e) => interests.contains(e.category));
    return _withDistances(matching.toList())
        .where((ed) => ed.distanceKm > kNearbyRadiusKm)
        .toList();
  }

  List<String> get availableCities =>
      kMockEvents.map((e) => e.city).toSet().toList()..sort();

  /// All events in [city], regardless of interests, so travelers can also
  /// discover something new. Callers can check [EventItem.category] against
  /// the user's interests to highlight recommended ones.
  List<EventItem> eventsInCity(String city) {
    return kMockEvents.where((e) => e.city == city).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }
}

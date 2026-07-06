class EventItem {
  final String id;
  final String title;
  final String category;
  final String city;
  final double lat;
  final double lng;
  final DateTime dateTime;
  final String description;

  /// Photos uploaded by the event organizer/user. Empty until they add some.
  final List<String> imageUrls;
  final String address;
  final String venueName;
  final String? phone;

  const EventItem({
    required this.id,
    required this.title,
    required this.category,
    required this.city,
    required this.lat,
    required this.lng,
    required this.dateTime,
    required this.description,
    this.imageUrls = const [],
    this.address = '',
    this.venueName = '',
    this.phone,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../providers/events_provider.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

/// Waze-style combined view: a minimalist, draggable map with event bubbles
/// on top, and a draggable sheet with the list underneath for quick scanning.
class NearbyMapScreen extends StatefulWidget {
  final List<String> interests;
  final EventsProvider eventsProvider;

  const NearbyMapScreen({super.key, required this.interests, required this.eventsProvider});

  @override
  State<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends State<NearbyMapScreen> {
  final MapController _mapController = MapController();

  void _focusOn(ll.LatLng point) {
    _mapController.move(point, 14);
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = widget.eventsProvider;
    if (eventsProvider.loadingLocation) {
      return const Center(child: CircularProgressIndicator());
    }
    final events = eventsProvider.nearbyEventsForInterests(widget.interests);
    final center = eventsProvider.lat != null && eventsProvider.lng != null
        ? ll.LatLng(eventsProvider.lat!, eventsProvider.lng!)
        : const ll.LatLng(4.7110, -74.0721);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 12,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: isDark
                  ? 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                  : 'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.eventfinder.event_finder',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 22,
                  height: 22,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
                    ),
                  ),
                ),
                ...events.map(
                  (ed) => Marker(
                    point: ll.LatLng(ed.event.lat, ed.event.lng),
                    width: 44,
                    height: 44,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => EventDetailScreen(event: ed.event)),
                      ),
                      child: _EventBubble(category: ed.event.category),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          right: 12,
          bottom: 220,
          child: FloatingActionButton.small(
            heroTag: 'recenter',
            onPressed: () => _focusOn(center),
            child: const Icon(Icons.my_location),
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.22,
          minChildSize: 0.12,
          maxChildSize: 0.75,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      events.isEmpty
                          ? 'No hay eventos cercanos con tus intereses'
                          : '${events.length} evento(s) cerca de ti',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: events.length,
                      itemBuilder: (context, i) => GestureDetector(
                        onTap: () => _focusOn(ll.LatLng(events[i].event.lat, events[i].event.lng)),
                        child: EventCard(eventWithDistance: events[i]),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

const Map<String, IconData> _categoryIcons = {
  'Conciertos': Icons.music_note,
  'Deportes': Icons.sports_soccer,
  'Videojuegos': Icons.sports_esports,
  'Arte': Icons.palette,
  'Tecnología': Icons.memory,
  'Comida': Icons.restaurant,
  'Cine': Icons.movie,
  'Familia': Icons.family_restroom,
};

class _EventBubble extends StatelessWidget {
  final String category;

  const _EventBubble({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
      ),
      child: Icon(
        _categoryIcons[category] ?? Icons.place,
        color: Theme.of(context).colorScheme.onPrimary,
        size: 22,
      ),
    );
  }
}

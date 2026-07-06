import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/events_provider.dart';
import '../screens/event_detail_screen.dart';

class EventCard extends StatelessWidget {
  final EventWithDistance eventWithDistance;
  final bool showDistance;

  const EventCard({super.key, required this.eventWithDistance, this.showDistance = true});

  @override
  Widget build(BuildContext context) {
    final event = eventWithDistance.event;
    final dateFormat = DateFormat('d MMM, HH:mm');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${event.category} · ${event.city}'),
            Text(dateFormat.format(event.dateTime)),
            if (showDistance)
              Text('${eventWithDistance.distanceKm.toStringAsFixed(1)} km de distancia'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
        ),
      ),
    );
  }
}

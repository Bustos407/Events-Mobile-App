import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event.dart';

class EventDetailScreen extends StatelessWidget {
  final EventItem event;

  const EventDetailScreen({super.key, required this.event});

  Future<void> _openDirections() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${event.lat},${event.lng}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE d MMMM, HH:mm');
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: event.imageUrls.isEmpty ? 0 : 220,
            pinned: true,
            title: Text(event.title),
            flexibleSpace: event.imageUrls.isEmpty
                ? null
                : FlexibleSpaceBar(
                    background: PageView(
                      children: event.imageUrls
                          .map((url) => Image.network(
                                url,
                                fit: BoxFit.cover,
                                // Decode at display resolution instead of full size to save RAM
                                // on low-end devices.
                                cacheWidth: 800,
                                errorBuilder: (_, error, stackTrace) => Container(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.image_not_supported, size: 48),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Chip(label: Text(event.category)),
                const SizedBox(height: 16),
                if (event.venueName.isNotEmpty)
                  Text(event.venueName, style: Theme.of(context).textTheme.titleMedium),
                if (event.address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 4),
                      Expanded(child: Text(event.address)),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 4),
                    Text(dateFormat.format(event.dateTime)),
                  ],
                ),
                if (event.phone != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 18),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _callPhone(event.phone!),
                        child: Text(
                          event.phone!,
                          style: const TextStyle(decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _openDirections,
                  icon: const Icon(Icons.directions),
                  label: const Text('Cómo llegar'),
                ),
                const SizedBox(height: 20),
                Text(event.description, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'La reventa/transferencia de boletos entre usuarios llegará en una '
                      'próxima versión de la app.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

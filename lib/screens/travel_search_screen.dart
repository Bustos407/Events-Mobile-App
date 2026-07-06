import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../providers/events_provider.dart';
import 'event_detail_screen.dart';

class TravelSearchScreen extends StatefulWidget {
  const TravelSearchScreen({super.key});

  @override
  State<TravelSearchScreen> createState() => _TravelSearchScreenState();
}

class _TravelSearchScreenState extends State<TravelSearchScreen> {
  String? _selectedCity;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final eventsProvider = context.watch<EventsProvider>();
    final interests = auth.user?.interests ?? [];
    final cities = eventsProvider.availableCities;
    final List<EventItem> results =
        _selectedCity == null ? [] : eventsProvider.eventsInCity(_selectedCity!);

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar en otra ciudad')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¿Planeando un viaje? Elige un destino y te mostramos todo lo que pasa ahí, '
              'para que también descubras algo nuevo.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCity,
              decoration: const InputDecoration(labelText: 'Ciudad destino'),
              items: cities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCity = v),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedCity == null
                  ? const Center(child: Text('Selecciona una ciudad para empezar.'))
                  : results.isEmpty
                      ? const Center(child: Text('No hay eventos registrados ahí todavía.'))
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, i) {
                            final event = results[i];
                            final matchesInterests = interests.contains(event.category);
                            final dateFormat = DateFormat('d MMM, HH:mm');
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: matchesInterests
                                    ? Icon(Icons.star,
                                        color: Theme.of(context).colorScheme.primary)
                                    : const Icon(Icons.explore_outlined),
                                title: Text(event.title),
                                subtitle: Text(
                                  '${event.category} · ${event.city}\n'
                                  '${dateFormat.format(event.dateTime)}',
                                ),
                                isThreeLine: true,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EventDetailScreen(event: event),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

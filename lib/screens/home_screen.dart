import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/events_provider.dart';
import '../providers/theme_provider.dart';
import 'interests_onboarding_screen.dart';
import 'login_screen.dart';
import 'nearby_map_screen.dart';
import 'travel_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _notifiedThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    await context.read<EventsProvider>().loadLocation();
    _maybeShowNotification();
  }

  void _maybeShowNotification() {
    if (_notifiedThisSession || !mounted) return;
    final auth = context.read<AuthProvider>();
    final eventsProvider = context.read<EventsProvider>();
    final interests = auth.user?.interests ?? [];
    final upcoming = eventsProvider.upcomingNotifications(interests);
    if (upcoming.isEmpty) return;
    _notifiedThisSession = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(
            '🔔 ${upcoming.length} evento(s) de tu interés están por comenzar cerca de ti: '
            '${upcoming.first.event.title}',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final eventsProvider = context.watch<EventsProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final interests = auth.user?.interests ?? [];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hola, ${auth.user?.name ?? ''}'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.place), text: 'Cerca de ti'),
              Tab(icon: Icon(Icons.flight_takeoff), text: 'Modo viaje'),
            ],
          ),
          actions: [
            PopupMenuButton<ThemeMode>(
              icon: Icon(themeProvider.icon),
              tooltip: 'Tema de la app',
              initialValue: themeProvider.mode,
              onSelected: themeProvider.setMode,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: ThemeMode.system,
                  child: Text('Automático (según el sistema)'),
                ),
                PopupMenuItem(value: ThemeMode.light, child: Text('Claro')),
                PopupMenuItem(value: ThemeMode.dark, child: Text('Oscuro')),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Editar intereses',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InterestsOnboardingScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            NearbyMapScreen(interests: interests, eventsProvider: eventsProvider),
            const TravelSearchScreen(),
          ],
        ),
      ),
    );
  }
}

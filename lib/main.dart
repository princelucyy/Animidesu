import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'services/anilist_api.dart';
import 'services/local_store.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final api = AniListApi();
  final store = LocalStore();
  runApp(AnimidesuApp(api: api, store: store));
}

class AnimidesuApp extends StatelessWidget {
  const AnimidesuApp({super.key, required this.api, required this.store});
  final AniListApi api;
  final LocalStore store;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF7C4DFF);
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    return MaterialApp(
      title: 'Animidesu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: const Color(0xFF0D0E13), inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder())),
      home: MainShell(api: api, store: store),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.api, required this.store});
  final AniListApi api;
  final LocalStore store;
  @override State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int _index = 0;
  @override Widget build(BuildContext context) {
    final pages = [HomeScreen(api: widget.api, store: widget.store), LibraryScreen(api: widget.api, store: widget.store), ScheduleScreen(api: widget.api), ProfileScreen(store: widget.store)];
    return Scaffold(body: IndexedStack(index: _index, children: pages), bottomNavigationBar: NavigationBar(selectedIndex: _index, onDestinationSelected: (i) => setState(() => _index = i), destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'), NavigationDestination(icon: Icon(Icons.bookmark_outline), selectedIcon: Icon(Icons.bookmark), label: 'Koleksi'), NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Jadwal'), NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil')]));
  }
}

import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../services/anilist_api.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, required this.api});
  final AniListApi api;
  @override State<ScheduleScreen> createState() => _ScheduleScreenState();
}
class _ScheduleScreenState extends State<ScheduleScreen> {
  late Future<List<Anime>> _future = widget.api.getHome();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Jadwal')),
    body: FutureBuilder<List<Anime>>(future: _future, builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (snap.hasError) return Center(child: Text('Gagal memuat jadwal: ${snap.error}'));
      final items = (snap.data ?? const <Anime>[]).where((e) => e.nextEpisode != null).toList();
      if (items.isEmpty) return const Center(child: Text('Belum ada jadwal tersedia.'));
      return RefreshIndicator(onRefresh: () async => setState(() => _future = widget.api.getHome()), child: ListView.separated(padding: const EdgeInsets.all(16), itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, i) { final a = items[i]; return Card(child: ListTile(leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(a.coverImage, width: 54, height: 74, fit: BoxFit.cover)), title: Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis), subtitle: Text('Episode berikutnya: ${a.nextEpisode}'), trailing: const Icon(Icons.chevron_right))); }));
    }),
  );
}

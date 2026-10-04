import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../services/anilist_api.dart';
import '../services/local_store.dart';
import '../widgets/anime_card.dart';
import 'detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.api, required this.store});
  final AniListApi api;
  final LocalStore store;
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Anime> _items = const [];
  Set<int> _favorites = {};
  bool _loading = true;
  String _tab = 'Favorit';
  Map<int, double> _progress = {};

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() => _loading = true);
    _favorites = await widget.store.favorites();
    _progress = await widget.store.progress();
    final ids = _tab == 'Favorit' ? _favorites : _progress.keys.toSet();
    final found = <Anime>[];
    for (final id in ids) {
      try { found.add(await widget.api.getDetails(id)); } catch (_) {}
    }
    if (mounted) setState(() { _items = found; _loading = false; });
  }
  Future<void> _toggle(Anime a) async { await widget.store.setFavorite(a.id, false); await _load(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Koleksi')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), child: SegmentedButton<String>(segments: const [ButtonSegment(value: 'Favorit', label: Text('Favorit'), icon: Icon(Icons.favorite)), ButtonSegment(value: 'Histori', label: Text('Histori'), icon: Icon(Icons.history))], selected: {_tab}, onSelectionChanged: (s) { setState(() => _tab = s.first); _load(); })),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _items.isEmpty ? const Center(child: Text('Belum ada koleksi.')) : GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .48, crossAxisSpacing: 12, mainAxisSpacing: 16), itemCount: _items.length, itemBuilder: (_, i) { final a = _items[i]; return AnimeCard(anime: a, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailScreen(anime: a, isFavorite: _favorites.contains(a.id), onFavorite: () => _toggle(a), getStreamApi: widget.store.streamApi, onProgress: (value) => widget.store.setProgress(a.id, value)))), isFavorite: _favorites.contains(a.id), onFavorite: () => _toggle(a)); }))
      ]),
    );
  }
}

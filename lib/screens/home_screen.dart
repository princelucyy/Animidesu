import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../services/anilist_api.dart';
import '../services/local_store.dart';
import '../widgets/anime_card.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api, required this.store});
  final AniListApi api;
  final LocalStore store;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Anime>> _future = widget.api.getHome();
  Set<int> _favorites = {};
  final _search = TextEditingController();
  List<Anime> _results = const [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _loadFavorites() async { final f = await widget.store.favorites(); if (mounted) setState(() => _favorites = f); }
  Future<void> _toggleFavorite(Anime a) async { final on = !_favorites.contains(a.id); await widget.store.setFavorite(a.id, on); await _loadFavorites(); }

  Future<void> _submitSearch() async {
    final q = _search.text.trim();
    if (q.isEmpty) return;
    setState(() => _isSearching = true);
    try { final r = await widget.api.search(q); if (mounted) setState(() => _results = r); }
    finally { if (mounted) setState(() => _isSearching = false); }
  }

  void _open(Anime a) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailScreen(anime: a, isFavorite: _favorites.contains(a.id), onFavorite: () => _toggleFavorite(a), getStreamApi: widget.store.streamApi, onProgress: (value) => widget.store.setProgress(a.id, value))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => setState(() => _future = widget.api.getHome()),
        child: CustomScrollView(slivers: [
          SliverAppBar(pinned: true, floating: true, title: const Text('Animidesu'), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))]),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 10), child: SearchBar(controller: _search, hintText: 'Cari anime, donghua, judul...', leading: const Icon(Icons.search), onSubmitted: (_) => _submitSearch(), trailing: [IconButton(onPressed: _submitSearch, icon: const Icon(Icons.arrow_forward))]))),
          if (_results.isNotEmpty || _isSearching) ...[
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Text('Hasil pencarian', style: Theme.of(context).textTheme.titleLarge))),
            if (_isSearching) const SliverToBoxAdapter(child: LinearProgressIndicator(minHeight: 2)),
            if (_results.isNotEmpty) _grid(_results),
          ],
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 8), child: Text('Beranda', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)))),
          SliverToBoxAdapter(child: FutureBuilder<List<Anime>>(future: _future, builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
            if (snap.hasError) return Padding(padding: const EdgeInsets.all(24), child: Text('Gagal memuat katalog: ${snap.error}'));
            final list = snap.data ?? const <Anime>[];
            return Column(children: [
              _section('Trending', list.take(10).toList()),
              _section('Airing / Terbaru', list.skip(10).take(10).toList()),
            ]);
          })),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ]),
      ),
    );
  }

  Widget _section(String title, List<Anime> items) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 10), child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
    SizedBox(height: 305, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => AnimeCard(anime: items[i], onTap: () => _open(items[i]), isFavorite: _favorites.contains(items[i].id), onFavorite: () => _toggleFavorite(items[i])))),
  ]);

  Widget _grid(List<Anime> items) => SliverPadding(padding: const EdgeInsets.all(16), sliver: SliverGrid(delegate: SliverChildBuilderDelegate((_, i) => AnimeCard(anime: items[i], onTap: () => _open(items[i]), isFavorite: _favorites.contains(items[i].id), onFavorite: () => _toggleFavorite(items[i])), childCount: items.length), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.48, crossAxisSpacing: 12, mainAxisSpacing: 16)));
}

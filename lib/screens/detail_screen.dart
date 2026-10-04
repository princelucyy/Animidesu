import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../services/stream_repository.dart';
import 'player_screen.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.anime, required this.isFavorite, required this.onFavorite, required this.getStreamApi, this.onProgress});
  final Anime anime;
  final bool isFavorite;
  final Future<void> Function() onFavorite;
  final Future<String?> Function() getStreamApi;
  final Future<void> Function(double value)? onProgress;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _repo = StreamRepository();
  int _episode = 1;
  bool _loadingStream = false;
  String? _error;

  Future<void> _play() async {
    final api = await widget.getStreamApi();
    if (api == null || api.isEmpty) {
      setState(() => _error = 'Streaming API belum dikonfigurasi. Buka Profil → Pengaturan → Streaming API.');
      return;
    }
    setState(() { _loadingStream = true; _error = null; });
    try {
      if (widget.onProgress != null) await widget.onProgress!(0.0);
      final streams = await _repo.resolve(baseUrl: api, animeId: widget.anime.id, episode: _episode);
      if (!mounted) return;
      if (streams.isEmpty) throw Exception('Tidak ada stream yang tersedia.');
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayerScreen(anime: widget.anime, episode: _episode, streams: streams, onProgress: widget.onProgress)));
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loadingStream = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.anime;
    final maxEpisodes = a.episodes ?? 12;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            actions: [IconButton(onPressed: widget.onFavorite, icon: Icon(widget.isFavorite ? Icons.favorite : Icons.favorite_border))],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 14, right: 58),
              title: Text(a.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (a.bannerImage != null && a.bannerImage!.isNotEmpty) Image.network(a.bannerImage!, fit: BoxFit.cover),
                  const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xFF111118)]))),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(spacing: 8, runSpacing: 8, children: [
                  Chip(label: Text(a.status ?? 'UNKNOWN')),
                  if (a.score != null) Chip(label: Text('Score ${a.score}')),
                  if (a.seasonYear != null) Chip(label: Text('${a.season ?? ''} ${a.seasonYear}')),
                ]),
                const SizedBox(height: 12),
                Text(a.description.isEmpty ? 'Deskripsi belum tersedia.' : a.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
                const SizedBox(height: 18),
                Text('Genre', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(spacing: 6, children: a.genres.map((g) => Chip(label: Text(g))).toList()),
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(child: DropdownButtonFormField<int>(
                    value: _episode,
                    decoration: const InputDecoration(labelText: 'Episode', border: OutlineInputBorder()),
                    items: [for (var i = 1; i <= maxEpisodes; i++) DropdownMenuItem(value: i, child: Text('Episode $i'))],
                    onChanged: (v) => setState(() => _episode = v ?? 1),
                  )),
                  const SizedBox(width: 12),
                  FilledButton.icon(onPressed: _loadingStream ? null : _play, icon: const Icon(Icons.play_arrow), label: Text(_loadingStream ? 'Memuat...' : 'Tonton')),
                ]),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

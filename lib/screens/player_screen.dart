import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../models/anime.dart';
import '../services/stream_repository.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.anime, required this.episode, required this.streams, this.onProgress});
  final Anime anime;
  final int episode;
  final List<StreamOption> streams;
  final Future<void> Function(double value)? onProgress;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player _player = Player();
  late final VideoController _controller = VideoController(_player);
  int _selected = 0;
  double _speed = 1.0;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _openSelected();
    _positionSub = _player.stream.position.listen((position) {
      if (widget.onProgress == null || _duration.inMilliseconds <= 0) return;
      widget.onProgress!((position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0).toDouble());
    });
    _durationSub = _player.stream.duration.listen((duration) => _duration = duration);
  }

  Future<void> _openSelected() async {
    final stream = widget.streams[_selected];
    await _player.open(Media(stream.url));
    await _player.setRate(_speed);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('${widget.anime.title} • E${widget.episode}'), backgroundColor: Colors.black),
      body: Column(
        children: [
          AspectRatio(aspectRatio: 16 / 9, child: Video(controller: _controller, controls: MaterialVideoControls)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Server streaming', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < widget.streams.length; i++)
                      ChoiceChip(
                        label: Text('${widget.streams[i].label}${widget.streams[i].quality == null ? '' : ' • ${widget.streams[i].quality}'}'),
                        selected: i == _selected,
                        onSelected: (_) async {
                          setState(() => _selected = i);
                          await _openSelected();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                ListTile(
                  title: const Text('Kecepatan'),
                  subtitle: Text('${_speed.toStringAsFixed(1)}x'),
                  trailing: DropdownButton<double>(
                    value: _speed,
                    items: const [0.5, 0.75, 1, 1.25, 1.5, 2].map((e) => DropdownMenuItem(value: e, child: Text('${e}x'))).toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() => _speed = value);
                      await _player.setRate(value);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Gunakan hanya URL video/HLS yang Anda miliki atau memiliki lisensi untuk didistribusikan.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

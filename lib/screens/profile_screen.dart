import 'dart:math';
import 'package:flutter/material.dart';
import '../services/local_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.store});
  final LocalStore store;
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  int _level = 1, _xp = 0, _tickets = 3;
  String? _pet;
  final _api = TextEditingController();
  final _pets = const ['Neko', 'Kitsune', 'Tanuki', 'Mochi', 'Kuro'];
  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _api.dispose(); super.dispose(); }
  Future<void> _load() async { final level = await widget.store.level(); final xp = await widget.store.xp(); final tickets = await widget.store.tickets(); final pet = await widget.store.pet(); final api = await widget.store.streamApi(); if (!mounted) return; setState(() { _level=level; _xp=xp; _tickets=tickets; _pet=pet; _api.text=api ?? ''; }); }
  Future<void> _gacha() async {
    if (!await widget.store.spendTicket()) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tiket gacha habis.'))); return; }
    final pet = _pets[Random().nextInt(_pets.length)];
    await widget.store.setPet(pet); await widget.store.addXp(20); await _load();
    if (mounted) showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Gacha berhasil!'), content: Text('Pet kamu: $pet'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
  }
  Future<void> _saveApi() async { await widget.store.setStreamApi(_api.text); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Streaming API tersimpan.'))); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profil')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [CircleAvatar(radius: 30, child: Text('A')), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Animidesu User', style: Theme.of(context).textTheme.titleLarge), Text('Level $_level • $_xp XP')]))]), const SizedBox(height: 16), LinearProgressIndicator(value: (_xp / max(1, _level * 100)).clamp(0.0, 1.0).toDouble()), const SizedBox(height: 8), Text('Pet: ${_pet ?? 'Belum punya'}')])),
      const SizedBox(height: 12),
      Card(child: Column(children: [ListTile(title: const Text('Gacha Pet'), subtitle: Text('Tiket: $_tickets'), leading: const Icon(Icons.casino_outlined), trailing: FilledButton(onPressed: _gacha, child: const Text('Coba'))), const Divider(height: 1), const ListTile(leading: Icon(Icons.wallpaper_outlined), title: Text('Wallpaper'), subtitle: Text('Arsitektur siap ditambahkan ke inventory.'))])),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Streaming API berlisensi', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8), TextField(controller: _api, keyboardType: TextInputType.url, decoration: const InputDecoration(hintText: 'https://server-anda.example/api/', border: OutlineInputBorder())), const SizedBox(height: 10), Align(alignment: Alignment.centerRight, child: FilledButton(onPressed: _saveApi, child: const Text('Simpan')))]))),
      const SizedBox(height: 12),
      const Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('Tentang Animidesu'), subtitle: Text('Client lintas platform. Metadata anime berasal dari AniList. Sumber video harus Anda miliki atau berlisensi.'))),
    ]),
  );
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime.dart';

class LocalStore {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  static const _favoritesKey = 'favorites';
  static const _historyKey = 'history';
  static const _progressKey = 'progress';
  static const _streamApiKey = 'stream_api';
  static const _levelKey = 'level';
  static const _xpKey = 'xp';
  static const _ticketsKey = 'tickets';
  static const _petKey = 'pet';

  Future<Set<int>> favorites() async => ((await _prefs.getStringList(_favoritesKey)) ?? const [])
      .map(int.tryParse)
      .whereType<int>()
      .toSet();

  Future<void> setFavorite(int id, bool enabled) async {
    final ids = await favorites();
    enabled ? ids.add(id) : ids.remove(id);
    await _prefs.setStringList(_favoritesKey, ids.map((e) => e.toString()).toList());
  }

  Future<Map<int, double>> progress() async {
    final raw = await _prefs.getString(_progressKey);
    if (raw == null || raw.isEmpty) return {};
    final map = (jsonDecode(raw) as Map<String, dynamic>);
    return map.map((k, v) => MapEntry(int.parse(k), (v as num).toDouble()));
  }

  Future<void> setProgress(int id, double value) async {
    final p = await progress();
    p[id] = value.clamp(0, 1);
    final json = p.map((k, v) => MapEntry(k.toString(), v));
    await _prefs.setString(_progressKey, jsonEncode(json));
    await _prefs.setStringList(_historyKey, p.keys.map((e) => e.toString()).toList());
  }

  Future<String?> streamApi() => _prefs.getString(_streamApiKey);
  Future<void> setStreamApi(String value) => _prefs.setString(_streamApiKey, value.trim());

  Future<int> level() async => await _prefs.getInt(_levelKey) ?? 1;
  Future<int> xp() async => await _prefs.getInt(_xpKey) ?? 0;
  Future<int> tickets() async => await _prefs.getInt(_ticketsKey) ?? 3;
  Future<String?> pet() async => _prefs.getString(_petKey);

  Future<void> addXp(int delta) async {
    var currentXp = await xp() + delta;
    var currentLevel = await level();
    final need = currentLevel * 100;
    if (currentXp >= need) {
      currentXp -= need;
      currentLevel += 1;
    }
    await _prefs.setInt(_xpKey, currentXp);
    await _prefs.setInt(_levelKey, currentLevel);
  }

  Future<bool> spendTicket() async {
    final t = await tickets();
    if (t <= 0) return false;
    await _prefs.setInt(_ticketsKey, t - 1);
    return true;
  }

  Future<void> setPet(String pet) => _prefs.setString(_petKey, pet);
}

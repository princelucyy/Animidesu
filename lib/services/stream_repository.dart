import 'dart:convert';
import 'package:http/http.dart' as http;

class StreamOption {
  const StreamOption({required this.url, required this.label, this.quality});
  final String url;
  final String label;
  final String? quality;
}

/// Adapter for a backend that you own or have permission to use.
/// Expected response: {"streams":[{"url":"https://...","label":"Main","quality":"1080p"}]}
class StreamRepository {
  StreamRepository({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<StreamOption>> resolve({
    required String baseUrl,
    required int animeId,
    required int episode,
    String language = 'id',
  }) async {
    if (baseUrl.trim().isEmpty) return const [];
    final root = Uri.parse(baseUrl.trim().endsWith('/') ? baseUrl.trim() : '${baseUrl.trim()}/');
    final uri = root.resolve('streams/$animeId/$episode?lang=$language');
    final response = await _client.get(uri, headers: {'Accept': 'application/json'});
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Stream API HTTP ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = (body['streams'] as List<dynamic>? ?? const []);
    return list.map((raw) {
      final item = raw as Map<String, dynamic>;
      final url = (item['url'] ?? '').toString();
      if (url.isEmpty) throw Exception('Stream URL kosong');
      return StreamOption(
        url: url,
        label: (item['label'] ?? 'Server').toString(),
        quality: item['quality']?.toString(),
      );
    }).toList();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime.dart';

class AniListApi {
  AniListApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static final Uri _endpoint = Uri.parse('https://graphql.anilist.co');

  Future<List<Anime>> getHome() async {
    const query = r'''
      query Home {
        trending: Page(page: 1, perPage: 12) {
          media(sort: TRENDING_DESC, type: ANIME) {
            ...mediaFields
          }
        }
        popular: Page(page: 1, perPage: 12) {
          media(sort: POPULARITY_DESC, type: ANIME) {
            ...mediaFields
          }
        }
        airing: Page(page: 1, perPage: 12) {
          media(sort: START_DATE_DESC, status: RELEASING, type: ANIME) {
            ...mediaFields
          }
        }
      }
      fragment mediaFields on Media {
        id
        title { romaji english native }
        coverImage { large extraLarge }
        bannerImage
        description(asHtml: false)
        episodes
        status
        genres
        averageScore
        season
        seasonYear
        nextAiringEpisode { episode airingAt }
      }
    ''';
    final data = await _post(query, {});
    final root = data['data'] as Map<String, dynamic>;
    final seen = <int>{};
    final items = <Anime>[];
    for (final key in ['trending', 'airing', 'popular']) {
      final page = root[key] as Map<String, dynamic>;
      for (final raw in (page['media'] as List<dynamic>)) {
        final anime = Anime.fromJson(raw as Map<String, dynamic>);
        if (seen.add(anime.id)) items.add(anime);
      }
    }
    return items;
  }

  Future<List<Anime>> search(String keyword) async {
    const query = r'''
      query Search($search: String) {
        Page(page: 1, perPage: 30) {
          media(search: $search, type: ANIME, sort: SEARCH_MATCH) {
            id
            title { romaji english native }
            coverImage { large extraLarge }
            bannerImage
            description(asHtml: false)
            episodes
            status
            genres
            averageScore
            season
            seasonYear
            nextAiringEpisode { episode airingAt }
          }
        }
      }
    ''';
    final data = await _post(query, {'search': keyword});
    final media = ((data['data'] as Map<String, dynamic>)['Page'] as Map<String, dynamic>)['media'] as List<dynamic>;
    return media.map((e) => Anime.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Anime> getDetails(int id) async {
    const query = r'''
      query Detail($id: Int) {
        Media(id: $id, type: ANIME) {
          id
          title { romaji english native }
          coverImage { large extraLarge }
          bannerImage
          description(asHtml: false)
          episodes
          status
          genres
          averageScore
          season
          seasonYear
          nextAiringEpisode { episode airingAt }
        }
      }
    ''';
    final data = await _post(query, {'id': id});
    return Anime.fromJson((data['data'] as Map<String, dynamic>)['Media'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> _post(String query, Map<String, dynamic> variables) async {
    final response = await _client.post(
      _endpoint,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'query': query, 'variables': variables}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('AniList HTTP ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['errors'] != null) {
      throw Exception('AniList API error');
    }
    return decoded;
  }
}

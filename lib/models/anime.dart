class Anime {
  const Anime({
    required this.id,
    required this.title,
    required this.coverImage,
    this.bannerImage,
    this.description = '',
    this.episodes,
    this.status,
    this.genres = const [],
    this.score,
    this.season,
    this.seasonYear,
    this.nextEpisode,
  });

  final int id;
  final String title;
  final String coverImage;
  final String? bannerImage;
  final String description;
  final int? episodes;
  final String? status;
  final List<String> genres;
  final int? score;
  final String? season;
  final int? seasonYear;
  final int? nextEpisode;

  factory Anime.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] ?? {}) as Map<String, dynamic>;
    final cover = (json['coverImage'] ?? {}) as Map<String, dynamic>;
    final next = json['nextAiringEpisode'];

    return Anime(
      id: json['id'] as int,
      title: (title['english'] ?? title['romaji'] ?? title['native'] ?? 'Tanpa Judul').toString(),
      coverImage: (cover['extraLarge'] ?? cover['large'] ?? cover['medium'] ?? '').toString(),
      bannerImage: (json['bannerImage'] ?? cover['large'])?.toString(),
      description: _stripHtml((json['description'] ?? '').toString()),
      episodes: json['episodes'] as int?,
      status: json['status']?.toString(),
      genres: (json['genres'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      score: json['averageScore'] as int?,
      season: json['season']?.toString(),
      seasonYear: json['seasonYear'] as int?,
      nextEpisode: next is Map<String, dynamic> ? next['episode'] as int? : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'coverImage': coverImage,
        'bannerImage': bannerImage,
        'description': description,
        'episodes': episodes,
        'status': status,
        'genres': genres,
        'score': score,
        'season': season,
        'seasonYear': seasonYear,
        'nextEpisode': nextEpisode,
      };

  static String _stripHtml(String value) => value
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&#039;', "'")
      .trim();
}

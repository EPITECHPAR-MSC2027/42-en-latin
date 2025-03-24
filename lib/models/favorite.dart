class Favorite {
  Favorite({
    required this.id,
    required this.name,
    required this.prefs,
    this.shortUrl,
    this.backgroundColor,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      name: json['name'],
      prefs: json['prefs'] ?? {},
      shortUrl: json['shortUrl'],
      backgroundColor: json['prefs']?['backgroundColor'],
    );
  }

  final String id;
  final String name;
  final Map<String, dynamic> prefs;
  final String? shortUrl;
  final String? backgroundColor;
} 

class Favorite {
  Favorite({
    required this.id,
    required this.name,
    required this.url,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      name: json['name'],
      url: json['url'],
    );
  }

  final String id;
  final String name;
  final String url;
} 

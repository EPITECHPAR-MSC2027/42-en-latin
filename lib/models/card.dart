class CardModel {

  CardModel({
    required this.id,
    required this.name,
    required this.desc,
  });

  /// Convertir un JSON en `CardModel`
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      name: json['name'],
      desc: json['desc'] ?? '',
    );
  }
  final String id;
  final String name;
  final String desc;
}

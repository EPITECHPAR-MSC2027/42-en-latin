/// Modèle représentant une carte.
///
/// Une carte contient un identifiant unique, un nom et une description.
class CardModel {
  /// Constructeur de la classe `CardModel`.
  ///
  /// [id] : Identifiant unique de la carte.
  /// [name] : Nom de la carte.
  /// [desc] : Description de la carte.
  /// [listId] : Identifiant de la liste à laquelle appartient la carte.
  CardModel({
    required this.id,
    required this.name,
    required this.desc,
    required this.listId,
  });

  /// Convertir un JSON en `CardModel`.
  ///
  /// [json] : Map contenant les données JSON.
  /// Retourne une instance de `CardModel`.
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      name: json['name'],
      desc: json['desc'] ?? '',
      listId: json['idList'],
    );
  }

  /// Méthode pour créer une copie modifiée d'un `CardModel`
  CardModel copyWith({String? id, String? name, String? desc, String? listId}) {
    return CardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      listId: listId ?? this.listId,
    );
  }

  /// Identifiant unique de la carte.
  final String id;

  /// Nom de la carte.
  final String name;

  /// Description de la carte.
  final String desc;

  /// Identifiant de la liste à laquelle appartient la carte.
  final String listId;
}

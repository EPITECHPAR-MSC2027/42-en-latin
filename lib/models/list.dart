/// Modèle représentant une liste.
///
/// Une liste contient un identifiant unique et un nom.
class ListModel {
  /// Constructeur de la classe `ListModel`.
  ///
  /// [id] : Identifiant unique de la liste.
  /// [name] : Nom de la liste.
  ListModel({
    required this.id,
    required this.name,
  });

  /// Convertir un JSON en `ListModel`.
  ///
  /// [json] : Map contenant les données JSON.
  /// Retourne une instance de `ListModel`.
  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['id'],
      name: json['name'],
    );
  }

  /// Identifiant unique de la liste.
  final String id;

  /// Nom de la liste.
  final String name;
}

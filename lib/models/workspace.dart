/// Modèle représentant un workspace.
///
/// Un workspace contient un identifiant unique, un nom d'affichage et une description optionnelle.
class Workspace {
  /// Constructeur de la classe `Workspace`.
  ///
  /// [id] : Identifiant unique du workspace.
  /// [displayName] : Nom d'affichage du workspace.
  /// [desc] : Description optionnelle du workspace.
  Workspace({
    required this.id,
    required this.displayName,
    this.desc,
  });

  /// Convertir un JSON en objet `Workspace`.
  ///
  /// [json] : Map contenant les données JSON.
  /// Retourne une instance de `Workspace`.
  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'],
      displayName: json['displayName'],
      desc: json['desc'],
    );
  }

  /// Identifiant unique du workspace.
  final String id;

  /// Nom d'affichage du workspace.
  final String displayName;

  /// Description optionnelle du workspace.
  final String? desc;

  /// Convertir un objet `Workspace` en JSON.
  ///
  /// Retourne une Map contenant les données JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'displayName': displayName,
      'desc': desc,
    };
  }
}

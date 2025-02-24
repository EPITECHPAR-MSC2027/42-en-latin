class Workspace {

  Workspace({
    required this.id,
    required this.displayName,
    this.desc,
  });

  /// Convertir un JSON en objet `Workspace`
  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'],
      displayName: json['displayName'],
      desc: json['desc'],
    );
  }
  final String id;
  final String displayName;
  final String? desc;

  /// Convertir un objet `Workspace` en JSON
  Map<String, dynamic> toJson() {
    return{
      'id': id,
      'displayName': displayName,
      'desc': desc,
    };
  }
}

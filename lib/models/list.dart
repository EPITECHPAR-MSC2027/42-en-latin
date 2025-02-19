class ListModel {
  final String id;
  final String name;

  ListModel({
    required this.id,
    required this.name,
  });

  /// Convertir un JSON en `ListModel`
  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

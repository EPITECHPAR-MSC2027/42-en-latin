class ListModel {

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
  final String id;
  final String name;
}

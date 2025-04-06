/// Represents a Trello board.
/// 
/// A board contains an [id], a [name], and a [desc] (description).
/// This class is used to model the data fetched from the Trello API.
class Board {  // desc est maintenant optionnel (String?)

  /// Creates a new instance of [Board].
  ///
  /// [id]: The unique identifier of the board.
  /// [name]: The name of the board.
  /// [desc]: The description of the board (peut être null).
  /// [lastOpened]: The last opened date of the board (can be null).
  Board({
    required this.id,
    required this.name,
    required this.desc,
    DateTime? lastOpened,
  }) : lastOpened = lastOpened ?? DateTime.now();

  /// Creates a [Board] instance from a JSON object.
  ///
  /// This factory constructor is used to parse JSON data returned by the Trello API.
  ///
  /// [json]: A map representing the JSON data.
  /// Returns a new [Board] instance.
  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'],
      name: json['name'],
      desc: json['desc'] ?? 'Pas de description',
      lastOpened: json['lastOpened'] != null 
          ? DateTime.parse(json['lastOpened'])
          : DateTime.now(),
    );
  }
  /// The unique identifier of the board.
  final String id;

  /// The name of the board.
  final String name;

  /// The description of the board.
  final String desc;

  /// The last opened date of the board.
  final DateTime lastOpened;

  /// Convert the Board instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': desc,
      'lastOpened': lastOpened.toIso8601String(),
    };
  }
}

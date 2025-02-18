/// Represents a Trello board.
///
/// A board contains an [id], a [name], and a [desc] (description).
/// This class is used to model the data fetched from the Trello API.
class Board {
  /// The unique identifier of the board.
  final String id;

  /// The name of the board.
  final String name;

  /// The description of the board.
  final String desc;

  /// Creates a new instance of [Board].
  ///
  /// [id]: The unique identifier of the board.
  /// [name]: The name of the board.
  /// [desc]: The description of the board.
  Board({required this.id, required this.name, required this.desc});

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
      desc: json['desc'],
    );
  }
}
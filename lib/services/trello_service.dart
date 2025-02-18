import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/board.dart';

/// Service for interacting with the Trello API.
///
/// This service allows fetching boards from Trello
/// using an API key and an authentication token.
class TrelloService {
  /// The API key for authenticating with Trello.
  final String apiKey;

  /// The authentication token for the Trello API.
  final String token;

  /// Creates an instance of [TrelloService].
  ///
  /// [apiKey]: The Trello API key.
  /// [token]: The Trello authentication token.
  TrelloService({required this.apiKey, required this.token});

  /// Fetches the list of boards from the Trello API.
  ///
  /// Returns a list of [Board] objects representing the user's boards.
  ///
  /// Throws an [Exception] if the request fails.
  Future<List<Board>> getBoards() async {
    final url = Uri.parse('https://api.trello.com/1/members/me/boards?key=$apiKey&token=$token');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> boardsJson = json.decode(response.body);
      return boardsJson.map((json) => Board.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load boards');
    }
  }
}
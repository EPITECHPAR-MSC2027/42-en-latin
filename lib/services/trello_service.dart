import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/board.dart';

/// Service for interacting with the Trello API.
/// This service allows fetching and creating boards on Trello.
class TrelloService {
  /// The API key for authenticating with Trello.
  final String apiKey;

  /// The authentication token for the Trello API.
  final String token;

  /// Base URL for Trello API
  final String baseUrl = "https://api.trello.com/1";

  /// Creates an instance of [TrelloService].
  TrelloService({required this.apiKey, required this.token});

  /// Fetches the list of boards from Trello.
  Future<List<Board>> getBoards() async {
    final url = Uri.parse('$baseUrl/members/me/boards?key=$apiKey&token=$token');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> boardsJson = json.decode(response.body);
      return boardsJson.map((json) => Board.fromJson(json)).toList();
    } else {
      throw Exception('❌ Failed to load boards');
    }
  }



  

  /// Creates a new board on Trello.
  Future<Board> createBoard(String boardName, String boardDesc) async {
    final url = Uri.parse('$baseUrl/boards/?key=$apiKey&token=$token');

    final response = await http.post(
      url,
      body: {'name': boardName, 'desc': boardDesc }, // Paramètre du board
      
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Board.fromJson(jsonResponse); // Retourne le board créé
    } else {
      throw Exception('❌ Failed to create board: ${response.statusCode}');
    }
  }
}

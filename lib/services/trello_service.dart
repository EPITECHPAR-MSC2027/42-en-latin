import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/board.dart';

/// Service for interacting with the Trello API.

class TrelloService {
  final String apiKey;
  final String token;
  final String baseUrl = 'https://api.trello.com/1';


  /// Creates an instance of [TrelloService].
  TrelloService({required this.apiKey, required this.token});

  Future<List<Board>> getBoards() async {
    final url = Uri.parse('$baseUrl/members/me/boards?key=$apiKey&token=$token');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> boardsJson = json.decode(response.body);
      return boardsJson.map((json) => Board.fromJson(json)).toList();
    } else {
      throw Exception('Erreur: impossible de charger les boards');
    }
  }

  /// **Créer un Workspace**
  Future<Map<String, dynamic>?> createWorkspace(String name, String displayName, String desc) async {
    final url = Uri.parse('$baseUrl/organizations?key=$apiKey&token=$token');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "displayName": displayName,
        "name": name,
        "desc": desc,
      }),
    );

    if (response.statusCode == 200) {
      print('Workspace créé: ${response.body}');
      return jsonDecode(response.body);
    } else {
      print('Erreur création workspace: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  /// **Mettre à jour un Workspace**
  Future<bool> updateWorkspace(String workspaceId, String newDisplayName, String newDesc) async {
    final url = Uri.parse('$baseUrl/organizations/$workspaceId?key=$apiKey&token=$token');

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "displayName": newDisplayName,
        "desc": newDesc,
      }),
    );

    if (response.statusCode == 200) {
      print('Workspace mis à jour avec succès');
      return true;
    } else {
      print('Erreur mise à jour workspace: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  /// **Supprimer un Workspace**
  Future<bool> deleteWorkspace(String workspaceId) async {
    final url = Uri.parse('$baseUrl/organizations/$workspaceId?key=$apiKey&token=$token');

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print('Workspace supprimé avec succès');
      return true;
    } else {
      print('Erreur suppression workspace: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  /// **Récupérer la liste des Workspaces**
  Future<List<Map<String, dynamic>>> getWorkspaces() async {
    final url = Uri.parse('$baseUrl/members/me/organizations?key=$apiKey&token=$token');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      print('Erreur récupération workspaces: ${response.statusCode} - ${response.body}');
      return [];
    }
  }

  /// **Récupérer les boards d'un workspace spécifique**
  Future<List<Board>> getBoardsByWorkspace(String workspaceId) async {
    final url = Uri.parse('$baseUrl/organizations/$workspaceId/boards?key=$apiKey&token=$token');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> boardsJson = json.decode(response.body);
      return boardsJson.map((json) => Board.fromJson(json)).toList();
    } else {
      throw Exception('Erreur: impossible de charger les boards du workspace $workspaceId');
    }
  }






    /// **Récupérer les listes d'un Board**
    Future<List<Map<String, dynamic>>> getListsByBoard(String boardId) async {
      final url = Uri.parse('$baseUrl/boards/$boardId/lists?key=$apiKey&token=$token');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Erreur: impossible de charger les listes du board $boardId');
      }
    }


}

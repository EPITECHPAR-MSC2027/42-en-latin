import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/board.dart';
import '../models/list.dart';

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

  //---------------------------------------------------------------------------//
  //                                 WORKSPACES                                //
  //---------------------------------------------------------------------------//

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


  //---------------------------------------------------------------------------//
  //                                  LISTS                                    //
  //---------------------------------------------------------------------------//

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

  /// **Créer une nouvelle liste dans un Board**
  Future<ListModel?> createList(String boardId, String name) async {
    final url = Uri.parse('$baseUrl/lists?key=$apiKey&token=$token');

    final response = await http.post(url, body: {
      'name': name,
      'idBoard': boardId,
    });

    if (response.statusCode == 200) {
      return ListModel.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  /// **Mettre à jour le nom d'une List**
  Future<bool> updateList(String listId, String newName) async {
    final url = Uri.parse('$baseUrl/lists/$listId?key=$apiKey&token=$token');

    final response = await http.put(url, body: {
      'name': newName,
    });

    return response.statusCode == 200;
  }

  /// **Supprimer une List**
  Future<bool> deleteList(String listId) async {
    final url = Uri.parse('$baseUrl/lists/$listId/closed?key=$apiKey&token=$token');

    final response = await http.put(url, body: {
      'value': 'true',
    });

    return response.statusCode == 200;
  }


  //---------------------------------------------------------------------------//
  //                                  CARDS                                    //
  //---------------------------------------------------------------------------//


    /// **Récupérer les cartes d'une liste**
  Future<List<Map<String, dynamic>>> getCardsByList(String listId) async {
    final url = Uri.parse('$baseUrl/lists/$listId/cards?key=$apiKey&token=$token');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Erreur: impossible de charger les cartes de la liste $listId');
    }
  }

  /// **Créer une nouvelle carte**
  Future<Map<String, dynamic>?> createCard(String listId, String name, String desc) async {
    final url = Uri.parse('$baseUrl/cards?key=$apiKey&token=$token');

    final response = await http.post(url, body: {
      'name': name,
      'desc': desc,
      'idList': listId,
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  /// **Mettre à jour une carte**
  Future<bool> updateCard(String cardId, String newName, String newDesc) async {
    final url = Uri.parse('$baseUrl/cards/$cardId?key=$apiKey&token=$token');

    final response = await http.put(url, body: {
      'name': newName,
      'desc': newDesc,
    });

    return response.statusCode == 200;
  }

  /// **Supprimer une carte**
  Future<bool> deleteCard(String cardId) async {
    final url = Uri.parse('$baseUrl/cards/$cardId?key=$apiKey&token=$token');

    final response = await http.delete(url);

    return response.statusCode == 200;
  }
}

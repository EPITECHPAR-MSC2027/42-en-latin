
import 'dart:convert';
import 'package:fluter/models/board.dart';
import 'package:fluter/models/list.dart';
import 'package:http/http.dart' as http;

/// Service for interacting with the Trello API.

class TrelloService {


  /// Creates an instance of [TrelloService].
  TrelloService({required this.apiKey, required this.token});
  final String apiKey;
  final String token;
  final String baseUrl = 'https://api.trello.com/1';

  Future<List<Board>> getBoards() async {
    final Uri url = Uri.parse('$baseUrl/members/me/boards?key=$apiKey&token=$token');
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> boardsJson = json.decode(response.body);
      return boardsJson.map((json) => Board.fromJson(json)).toList();
    } else {
      throw Exception('Erreur: impossible de charger les boards');
    }
  }


  Future<Map<String, dynamic>?> createBoard(String workspaceId, String name , String  desc) async {
  final Uri url = Uri.parse('$baseUrl/boards?key=$apiKey&token=$token');

  final http.Response response = await http.post(
    url,
    headers: <String, String>{'Content-Type': 'application/json'},
    body: jsonEncode(<String, String>{
      'name': name,
      'desc': desc,
     'idOrganization': workspaceId, 
    }),
    
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print('Erreur création board: ${response.statusCode} - ${response.body}');
    return null;
  }
}





/// **Supprimer un Board et tout son contenu (listes et cartes)**
Future<bool> deleteBoard(String boardId) async {
  try {
    // 1. Récupérer toutes les listes du board
    final List<Map<String, dynamic>> lists = await getListsByBoard(boardId);

    for (Map<String, dynamic> list in lists) {
      final listId = list['id'];

      // 2. Récupérer toutes les cartes de la liste
      final List<Map<String, dynamic>> cards = await getCardsByList(listId);

      // 3. Supprimer chaque carte
      for (Map<String, dynamic> card in cards) {
        await deleteCard(card['id']);
      }

      // 4. Archiver la liste
      await deleteList(listId);
    }

    // 5. Supprimer le board
    final Uri url = Uri.parse('$baseUrl/boards/$boardId?key=$apiKey&token=$token');
    final http.Response response = await http.delete(url);

    if (response.statusCode == 200) {
      print('Board supprimé avec succès');
      return true;
    } else {
      print('Erreur suppression board: ${response.statusCode} - ${response.body}');
      return false;
    }
  } catch (e) {
    print('Erreur lors de la suppression du board: $e');
    return false;
  }
}

  Future<bool> updateBoard(String boardId,String newName, String newDesc) async {
  final Uri url = Uri.parse('$baseUrl/boards/$boardId?key=$apiKey&token=$token');


final http.Response response = await http.put(
      url,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'Name': newName,
        'desc': newDesc,
      }),
    );

  if (response.statusCode == 200) {
    print('Board mis à jour avec succès');
    return true;
  } else {
    print('Erreur mise à jour board: ${response.statusCode} - ${response.body}');
    return false;
  }
}





  //---------------------------------------------------------------------------//
  //                                 WORKSPACES                                //
  //---------------------------------------------------------------------------//

  /// **Créer un Workspace**
  Future<Map<String, dynamic>?> createWorkspace(String name, String displayName, String desc) async {
    final Uri url = Uri.parse('$baseUrl/organizations?key=$apiKey&token=$token');

    final http.Response response = await http.post(
      url,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'displayName': displayName,
        'name': name,
        'desc': desc,
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
    final Uri url = Uri.parse('$baseUrl/organizations/$workspaceId?key=$apiKey&token=$token');

    final http.Response response = await http.put(
      url,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'displayName': newDisplayName,
        'desc': newDesc,
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
    final Uri url = Uri.parse('$baseUrl/organizations/$workspaceId?key=$apiKey&token=$token');

    final http.Response response = await http.delete(url);

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
    final Uri url = Uri.parse('$baseUrl/members/me/organizations?key=$apiKey&token=$token');

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      print('Erreur récupération workspaces: ${response.statusCode} - ${response.body}');
      return <Map<String, dynamic>>[];
    }
  }

  /// **Récupérer les boards d'un workspace spécifique**
  Future<List<Board>> getBoardsByWorkspace(String workspaceId) async {
    final Uri url = Uri.parse('$baseUrl/organizations/$workspaceId/boards?key=$apiKey&token=$token');

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> boardsJson = json.decode(response.body);
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
    final Uri url = Uri.parse('$baseUrl/boards/$boardId/lists?key=$apiKey&token=$token');

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Erreur: impossible de charger les listes du board $boardId');
    }
  }

  /// **Créer une nouvelle liste dans un Board**
  Future<ListModel?> createList(String boardId, String name) async {
    final Uri url = Uri.parse('$baseUrl/lists?key=$apiKey&token=$token');

    final http.Response response = await http.post(url, body: <String, String>{
      'name': name,
      'idBoard': boardId,
    },);

    if (response.statusCode == 200) {
      return ListModel.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  /// **Mettre à jour le nom d'une List**
  Future<bool> updateList(String listId, String newName) async {
    final Uri url = Uri.parse('$baseUrl/lists/$listId?key=$apiKey&token=$token');

    final http.Response response = await http.put(url, body: <String, String>{
      'name': newName,
    },);

    return response.statusCode == 200;
  }

  /// **Supprimer une List**
  Future<bool> deleteList(String listId) async {
    final Uri url = Uri.parse('$baseUrl/lists/$listId/closed?key=$apiKey&token=$token');

    final http.Response response = await http.put(url, body: <String, String>{
      'value': 'true',
    },);

    return response.statusCode == 200;
  }


  //---------------------------------------------------------------------------//
  //                                  CARDS                                    //
  //---------------------------------------------------------------------------//


    /// **Récupérer les cartes d'une liste**
  Future<List<Map<String, dynamic>>> getCardsByList(String listId) async {
    final Uri url = Uri.parse('$baseUrl/lists/$listId/cards?key=$apiKey&token=$token');

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Erreur: impossible de charger les cartes de la liste $listId');
    }
  }

  /// **Créer une nouvelle carte**
  Future<Map<String, dynamic>?> createCard(String listId, String name, String desc) async {
    final Uri url = Uri.parse('$baseUrl/cards?key=$apiKey&token=$token');

    final http.Response response = await http.post(url, body: <String, String>{
      'name': name,
      'desc': desc,
      'idList': listId,
    },);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  /// **Mettre à jour une carte**
  Future<bool> updateCard(String cardId, String newName, String newDesc) async {
    final Uri url = Uri.parse('$baseUrl/cards/$cardId?key=$apiKey&token=$token');

    final http.Response response = await http.put(url, body: <String, String>{
      'name': newName,
      'desc': newDesc,
    },);

    return response.statusCode == 200;
  }

  /// **Supprimer une carte**
  Future<bool> deleteCard(String cardId) async {
    final Uri url = Uri.parse('$baseUrl/cards/$cardId?key=$apiKey&token=$token');

    final http.Response response = await http.delete(url);

    return response.statusCode == 200;
  }
}

import 'dart:convert';

import 'package:fluter/models/board.dart';
import 'package:fluter/models/list.dart';
import 'package:fluter/models/notification.dart';
import 'package:fluter/utils/templates.dart'; // Import des templates
import 'package:http/http.dart' as http;

/// Service permettant de gérer les données de l'API Trello

class TrelloService {
  /// Crée une nouvelle instance de TrelloService
  TrelloService({required this.apiKey, required this.token});

  /// La clé API de l'application Trello
  final String apiKey;

  /// Le token d'accès à l'API Trello
  final String token;

  /// L'URL de base de l'API Trello
  final String baseUrl = 'https://api.trello.com/1';

  //---------------------------------------------------------------------------//
  //                                  BOARDS                                   //
  //---------------------------------------------------------------------------//

  /// **Récupérer la liste des Boards**

  Future<List<Board>> getBoards() async {
    final Uri url = Uri.parse(
      '$baseUrl/members/me/boards?key=$apiKey&token=$token',
    );
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> boardsJson = json.decode(response.body);
      return boardsJson.map((dynamic json) => Board.fromJson(json)).toList();
    } else {
      throw Exception('Erreur: impossible de charger les boards');
    }
  }

  /// **Créer un board avec ou sans template**
  Future<Map<String, dynamic>?> createBoard(
    String workspaceId,
    String name,
    String desc, {
    String? templateId, // Template optionnel
  }) async {
    final Uri url = Uri.parse('$baseUrl/boards?key=$apiKey&token=$token');

    // Construction du body JSON
    final Map<String, String> body = {
      'name': name,
      'desc': desc,
      'idOrganization': workspaceId,
    };

    if (templateId != null) {
      body['idBoardSource'] = templateId; // Ajout du template si sélectionné
    }

    try {
      final http.Response response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } 
      
    } catch (e) {
      throw Exception('Erreur lors de la création du board : $e');
    }
      return null;
    
  }

  /// **Créer un board en appliquant un template**
  Future<Map<String, dynamic>?> createBoardWithTemplate(
    String workspaceId,
    String name,
    String desc,
    String templateId,
  ) async {
    // 1️⃣ Créer un board vide
    final board = await createBoard(workspaceId, name, desc);
    if (board == null || !board.containsKey('id')) return null;

    final String boardId = board['id'];

    // 2️⃣ Supprimer toutes les listes existantes avant d'ajouter le template
    await deleteAllLists(boardId);

    // 3️⃣ Vérifier si le template existe
    final Map<String, List<String>>? template = templateCards[templateId];
    if (template == null) {
      return null;
    }

    // 4️⃣ Ajouter les listes et cartes du template
    for (final entry in template.entries) {
      final String listName = entry.key;
      final List<String> cards = entry.value;

      // Créer la liste
      final list = await createList(boardId, listName);
      if (list == null) continue;

      final String listId = list.id;

      // Ajouter les cartes
      for (final String cardName in cards) {
        await createCard(listId, cardName, ''); // Description vide
      }
    }

    return board;
  }

  /// **Supprimer un Board et tout son contenu (listes et cartes)**
  Future<bool> deleteBoard(String boardId) async {
  try {
    final Uri url = Uri.parse('$baseUrl/boards/$boardId?key=$apiKey&token=$token');
    final http.Response response = await http.delete(url);

    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

  /// **Mettre à jour un Board**
  Future<bool> updateBoard(
    String boardId,
    String newName,
    String newDesc,
  ) async {
    final Uri url = Uri.parse(
      '$baseUrl/boards/$boardId?key=$apiKey&token=$token',
    );

    final http.Response response = await http.put(
      url,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{'Name': newName, 'desc': newDesc}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Map<String, String>>> getBoardTemplates() async {
    final Uri url = Uri.parse(
      '$baseUrl/boardTemplates?key=$apiKey&token=$token',
    );

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      // Convertir les valeurs dynamiques en String pour correspondre à List<Map<String, String>>
      final List<Map<String, String>> templates =
          data.map((template) {
            return {
              'id': template['id'].toString(),
              'name': template['name'].toString(),
            };
          }).toList();

      return templates;
    } else {
      return [];
    }
  }

  /// **Mettre à jour la date de dernière ouverture d'un board**
  Future<bool> updateBoardLastOpened(String boardId) async {
    final Uri url = Uri.parse(
      '$baseUrl/boards/$boardId?key=$apiKey&token=$token',
    );

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'lastOpened': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Erreur lors de la mise à jour de la date d'ouverture : $e");
    }
  }

  //---------------------------------------------------------------------------//
  //                                 WORKSPACES                                //
  //---------------------------------------------------------------------------//

  /// **Créer un Workspace**
  Future<Map<String, dynamic>?> createWorkspace(
    String name,
    String displayName,
    String desc,
  ) async {
    final Uri url = Uri.parse(
      '$baseUrl/organizations?key=$apiKey&token=$token',
    );

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
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  /// **Mettre à jour un Workspace**
  Future<bool> updateWorkspace(
    String workspaceId,
    String newDisplayName,
    String newDesc,
  ) async {
    final Uri url = Uri.parse(
      '$baseUrl/organizations/$workspaceId?key=$apiKey&token=$token',
    );

    final http.Response response = await http.put(
      url,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'displayName': newDisplayName,
        'desc': newDesc,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// **Supprimer un Workspace**
  Future<bool> deleteWorkspace(String workspaceId) async {
    final Uri url = Uri.parse(
      '$baseUrl/organizations/$workspaceId?key=$apiKey&token=$token',
    );

    final http.Response response = await http.delete(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// **Récupérer la liste des Workspaces**
  Future<List<Map<String, dynamic>>> getWorkspaces() async {
    final Uri url = Uri.parse(
      '$baseUrl/members/me/organizations?key=$apiKey&token=$token',
    );

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      return <Map<String, dynamic>>[];
    }
  }

  /// **Récupérer les boards d'un workspace spécifique**
  Future<List<Board>> getBoardsByWorkspace(String workspaceId) async {
    final Uri url = Uri.parse(
      '$baseUrl/organizations/$workspaceId/boards?key=$apiKey&token=$token',
    );

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> boardsJson = json.decode(response.body);
      return boardsJson.map((dynamic json) => Board.fromJson(json)).toList();
    } else {
      throw Exception(
        'Erreur: impossible de charger les boards du workspace $workspaceId',
      );
    }
  }

  //---------------------------------------------------------------------------//
  //                                  LISTS                                    //
  //---------------------------------------------------------------------------//

  /// **Récupérer les listes d'un Board**
  Future<List<Map<String, dynamic>>> getListsByBoard(String boardId) async {
    final Uri url = Uri.parse(
      '$baseUrl/boards/$boardId/lists?key=$apiKey&token=$token',
    );

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception(
        'Erreur: impossible de charger les listes du board $boardId',
      );
    }
  }

  /// **Créer une nouvelle liste dans un Board**
  Future<ListModel?> createList(String boardId, String name) async {
    final Uri url = Uri.parse('$baseUrl/lists?key=$apiKey&token=$token');

    final http.Response response = await http.post(
      url,
      body: <String, String>{'name': name, 'idBoard': boardId},
    );

    if (response.statusCode == 200) {
      return ListModel.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  /// **Mettre à jour le nom d'une List**
  Future<bool> updateList(String listId, String newName) async {
    final Uri url = Uri.parse(
      '$baseUrl/lists/$listId?key=$apiKey&token=$token',
    );

    final http.Response response = await http.put(
      url,
      body: <String, String>{'name': newName},
    );

    return response.statusCode == 200;
  }

  /// **Supprimer une List**
  Future<bool> deleteList(String listId) async {
    final Uri url = Uri.parse(
      '$baseUrl/lists/$listId/closed?key=$apiKey&token=$token',
    );

    final http.Response response = await http.put(
      url,
      body: <String, String>{'value': 'true'},
    );

    return response.statusCode == 200;
  }

  Future<void> deleteAllLists(String boardId) async {
    final Uri url = Uri.parse(
      '$baseUrl/boards/$boardId/lists?key=$apiKey&token=$token',
    );
    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> lists = jsonDecode(response.body);

      for (final list in lists) {
        final Uri deleteUrl = Uri.parse(
          '$baseUrl/lists/${list["id"]}/closed?key=$apiKey&token=$token',
        );
        await http.put(deleteUrl, body: {'value': 'true'}); // ✅ Ferme la liste
     
      }
    } 
  }

  //---------------------------------------------------------------------------//
  //                                  CARDS                                    //
  //---------------------------------------------------------------------------//

  /// **Récupérer les cartes d'une liste**
  Future<List<Map<String, dynamic>>> getCardsByList(String listId) async {
    final Uri url = Uri.parse(
      '$baseUrl/lists/$listId/cards?key=$apiKey&token=$token',
    );

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception(
        'Erreur: impossible de charger les cartes de la liste $listId',
      );
    }
  }

  /// **Créer une nouvelle carte**
  Future<Map<String, dynamic>?> createCard(
    String listId,
    String name,
    String desc,
  ) async {
    final Uri url = Uri.parse('$baseUrl/cards?key=$apiKey&token=$token');

    final http.Response response = await http.post(
      url,
      body: <String, String>{'name': name, 'desc': desc, 'idList': listId},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  /// **Mettre à jour une carte**
  Future<bool> updateCard(String cardId, String newName, String newDesc) async {
    final Uri url = Uri.parse(
      '$baseUrl/cards/$cardId?key=$apiKey&token=$token',
    );

    final http.Response response = await http.put(
      url,
      body: <String, String>{'name': newName, 'desc': newDesc},
    );

    return response.statusCode == 200;
  }

  /// **Supprimer une carte**
  Future<bool> deleteCard(String cardId) async {
    final Uri url = Uri.parse(
      '$baseUrl/cards/$cardId?key=$apiKey&token=$token',
    );

    final http.Response response = await http.delete(url);

    return response.statusCode == 200;
  }

  //---------------------------------------------------------------------------//
  //                              NOTIFICATIONS                                 //
  //---------------------------------------------------------------------------//

  /// **Récupérer les notifications**
  Future<List<TrelloNotification>> getNotifications() async {
    final Uri url = Uri.parse(
      '$baseUrl/members/me/notifications?key=$apiKey&token=$token&limit=50&read_filter=all&memberCreator=true&memberCreator_fields=fullName&board=true&board_fields=name&card=true&card_fields=name&list=true&list_fields=name',
    );

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> notificationsJson = json.decode(response.body);
      return notificationsJson.map((json) {
        // Extraire les informations du board si présentes
        String? boardId;
        String? boardName;
        if (json['data']?['board'] != null) {
          boardId = json['data']['board']['id'];
          boardName = json['data']['board']['name'];
        }

        return TrelloNotification(
          id: json['id'],
          type: json['type'],
          message: json['data']?['text'] ?? _getDefaultMessage(json),
          date: DateTime.parse(json['date']),
          isRead: !json['unread'],
          boardId: boardId,
          boardName: boardName,
        );
      }).toList();
    } else {
      throw Exception('Erreur: impossible de charger les notifications');
    }
  }

  /// Obtient un message par défaut si le texte n'est pas disponible
  String _getDefaultMessage(Map<String, dynamic> json) {
    final memberName = json['memberCreator']?['fullName'] ?? "Quelqu'un";
    final boardName = json['data']?['board']?['name'] ?? '';
    final cardName = json['data']?['card']?['name'] ?? '';
    final listName = json['data']?['list']?['name'] ?? '';

    return '$memberName a effectué une action${boardName.isNotEmpty ? ' sur le board $boardName' : ''}'
           '${cardName.isNotEmpty ? ' (carte: $cardName)' : ''}'
           '${listName.isNotEmpty ? ' dans la liste $listName' : ''}';
  }

  /// **Marquer une notification comme lue**
  Future<bool> markNotificationAsRead(String notificationId) async {
    final Uri url = Uri.parse(
      '$baseUrl/notifications/$notificationId?key=$apiKey&token=$token',
    );

    final http.Response response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'unread': false}),
    );

    return response.statusCode == 200;
  }

  /// **Marquer toutes les notifications comme lues**
  Future<bool> markAllNotificationsAsRead() async {
    final Uri url = Uri.parse(
      '$baseUrl/notifications?key=$apiKey&token=$token',
    );

    final http.Response response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'unread': false}),
    );

    return response.statusCode == 200;
  }

  //---------------------------------------------------------------------------//
  //                                  USER INFO                                  //
  //---------------------------------------------------------------------------//

  /// **Récupérer les informations de l'utilisateur**
  Future<Map<String, dynamic>> getUserInfo() async {
    final Uri url = Uri.parse(
      '$baseUrl/members/me?key=$apiKey&token=$token&fields=all',
    );

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur: impossible de charger les informations utilisateur');
    }
  }

  /// **Récupérer les favoris**
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final Uri url = Uri.parse(
      '$baseUrl/members/me/boards?key=$apiKey&token=$token&filter=starred',
    );

    final http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Erreur: impossible de charger les favoris');
    }
  }
}

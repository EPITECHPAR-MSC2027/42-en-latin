import 'package:fluter/models/board.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:fluter/utils/templates.dart'; // ✅ Import des templates en dur
import 'package:flutter/material.dart';

/// **Classe BoardsProvider**
class BoardsProvider with ChangeNotifier {
  /// Constructeur
  BoardsProvider({required TrelloService trelloService}) : _trelloService = trelloService;
  final TrelloService _trelloService;

  List<Board> _boards = [];
  List<Board> get boards => _boards;

  /// Liste des templates récupérés
  List<Map<String, String>> _templates = templateCards.keys.map((String key) {
    return {'id': key, 'name': key}; // Convertit en liste utilisable
  }).toList();

  /// Getter pour les templates
  List<Map<String, String>> get templates => _templates;

  /// **Ajouter un Board avec ou sans template**
  Future<void> addBoard(
  String workspaceId, 
  String boardName, 
  String boardDesc, 
  {String? templateId,}
) async {
  try {
    if (templateId != null && templateCards.containsKey(templateId)) {
      // ✅ Créer un board AVEC un template local
      final board = await _trelloService.createBoardWithTemplate(
        workspaceId, boardName, boardDesc, templateId,
      );

      if (board != null) {
        notifyListeners(); // ✅ Informe les listeners qu'un changement a eu lieu
      }
    }
  } catch (error) {
    throw Exception('Erreur lors de la création du board : $error');
  }
}

  /// **Supprimer un board**
  Future<void> removeBoard(String boardId) async {
    try {
      final bool success = await _trelloService.deleteBoard(boardId);
      if (success) notifyListeners();

    } catch (error) {
      throw Exception('Erreur lors de la suppression du board : $error');
    }
  }


  /// **Modifier un board**
  Future<void> editBoard(String boardId, String newName, String newDesc) async {
    try {
      final bool success = await _trelloService.updateBoard(boardId, newName, newDesc);
      
      if (success) {
        notifyListeners(); // Informe les widgets que les données ont changé
      } 
    } catch (error) {
     
      throw Exception('Erreur lors de la modification du board : $error');
    }
  }

  Future<void> fetchTemplates() async {
    try {
      final List<Map<String, dynamic>> fetchedTemplates = await _trelloService.getBoardTemplates();

      _templates = fetchedTemplates.map((template) {
        return {
          'id': template['id'].toString(),
          'name': template['name'].toString(),
        };
      }).toList();

      notifyListeners();
    } catch (error) {
      throw Exception('Erreur lors du chargement des templates : $error');
    
    }
  }

  /// Charger tous les boards
  Future<void> fetchBoards() async {
    try {
      _boards = await _trelloService.getBoards();
      notifyListeners();
    } catch (error) {
      throw Exception('Erreur lors de la récupération des boards : $error');
    }
  }
}

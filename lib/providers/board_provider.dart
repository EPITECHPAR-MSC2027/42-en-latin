import 'package:fluter/services/trello_service.dart';
import 'package:flutter/material.dart';
import 'package:fluter/utils/templates.dart'; // ✅ Import des templates en dur

class BoardsProvider with ChangeNotifier {
  BoardsProvider({required TrelloService trelloService}) : _trelloService = trelloService;
  final TrelloService _trelloService;

  /// Liste des templates récupérés
  List<Map<String, String>> _templates = templateCards.keys.map((key) {
    return {'id': key, 'name': key}; // Convertit en liste utilisable
  }).toList();

  List<Map<String, String>> get templates => _templates;

  /// **Ajouter un Board avec ou sans template**
  Future<void> addBoard(
  String workspaceId, 
  String boardName, 
  String boardDesc, 
  {String? templateId}
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


   // **Modifier un board**
  Future<void> editBoard(String boardId, String newName, String newDesc) async {
    try {
      final bool success = await _trelloService.updateBoard(boardId, newName, newDesc);
      
      if (success) {
        notifyListeners(); // Informe les widgets que les données ont changé
      } else {
        print('La mise à jour du board a échoué');
      }
    } catch (error) {
      print('Erreur lors de la modification du board : $error');
      throw Exception('Erreur lors de la modification du board : $error');
    }
  }

  Future<void> fetchTemplates() async {
  try {
    List<Map<String, dynamic>> fetchedTemplates = await _trelloService.getBoardTemplates();

    _templates = fetchedTemplates.map((template) {
      return {
        'id': template['id'].toString(),
        'name': template['name'].toString(),
      };
    }).toList();

    notifyListeners(); // Mise à jour de l'interface
  } catch (error) {
    print('Erreur lors du chargement des templates: $error');
  }
}

}

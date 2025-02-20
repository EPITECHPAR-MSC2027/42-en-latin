import 'package:fluter/services/trello_service.dart';
import 'package:flutter/material.dart';

class BoardsProvider with ChangeNotifier {
  final TrelloService _trelloService;

  BoardsProvider({required TrelloService trelloService}) : _trelloService = trelloService;

  // **Créer un board dans un workspace**
  Future<void> addBoard(String workspaceId, String boardName, String boardDesc) async {
    try {
      final newBoardJson = await _trelloService.createBoard(workspaceId, boardName, boardDesc);
      
      if (newBoardJson != null) {
        notifyListeners(); // Informe les listeners qu'un changement a eu lieu
      }
      
    } catch (error) {
      throw Exception('Erreur lors de la création du board : $error');
    }
  }

  // **Supprimer un board**
  Future<void> removeBoard(String boardId) async {
    try {
      // await _trelloService.deleteBoard(boardId);
      notifyListeners();
    } catch (error) {
      throw Exception('Erreur lors de la suppression du board : $error');
    }
  }

  // **Modifier un board**
  Future<void> editBoard(String boardId, String newName, String newDesc) async {
    try {
      // await _trelloService.updateBoard(boardId, newName, newDesc);
      notifyListeners();
    } catch (error) {
      throw Exception('Erreur lors de la modification du board : $error');
    }
  }
}
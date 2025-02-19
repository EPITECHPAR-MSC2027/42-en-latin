// lib/providers/boards_provider.dart
import 'package:flutter/material.dart';
import 'package:fluter/models/board.dart';
import '../services/trello_service.dart';
import '../models/workspace.dart';
import 'workspace_provider.dart';
class BoardsProvider with ChangeNotifier {
  final TrelloService _trelloService;

  

  BoardsProvider({required TrelloService trelloService}) : _trelloService = trelloService;

 
// **Créer un board dans un workspace**
  Future<void> createBoard(
    String workspaceId,
    String boardName,
    String boardDesc,
    WorkspaceProvider workspaceProvider // On passe workspaceProvider comme paramètre
  ) async {
    try {
      final newBoardJson = await _trelloService.createBoard(workspaceId, boardName, boardDesc);
      if (newBoardJson != null) {
        final newBoard = Board.fromJson(newBoardJson);
        workspaceProvider.workspaceBoards.add(newBoard);  // Ajouter à workspaceBoards du WorkspaceProvider
        notifyListeners(); // Mettre à jour l'UI
      }
    } catch (error) {
      throw Exception('Erreur lors de la création du board');
    }
  }
}


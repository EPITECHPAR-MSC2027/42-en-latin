import 'dart:async';
import 'dart:developer' as developer;

import 'package:fluter/models/board.dart';
import 'package:fluter/services/storage_service.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:fluter/utils/templates.dart'; // ✅ Import des templates en dur
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// **Classe BoardsProvider**
class BoardsProvider with ChangeNotifier {
  /// Constructeur
  BoardsProvider({required TrelloService trelloService}) : _trelloService = trelloService {
    _storageService = StorageService();
    developer.log('BoardsProvider initialisé');
    unawaited(fetchBoards());
  }
  final TrelloService _trelloService;
  late final StorageService _storageService;

  List<Board> _boards = [];
  List<Board> _recentBoards = [];
  bool _isLoading = false;
  String? _error;

  List<Board> get boards => _boards;
  List<Board> get recentBoards => _recentBoards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Liste des templates récupérés
  List<Map<String, String>> _templates = templateCards.keys.map((String key) {
    return {'id': key, 'name': key}; // Convertit en liste utilisable
  }).toList();

  /// Getter pour les templates
  List<Map<String, String>> get templates => _templates;

  /// **Récupérer les boards récents**
  Future<List<Board>> getRecentBoards({int limit = 5}) async {
    try {
      final boards = await _trelloService.getRecentBoards(limit: limit);
      developer.log('Nombre de boards récents récupérés: ${boards.length}');
      return boards;
    } catch (e) {
      developer.log('Erreur lors de la récupération des boards récents: $e');
      throw Exception('Erreur: impossible de charger les boards récents');
    }
  }

  /// Marquer un board comme récemment ouvert
  Future<void> markBoardAsOpened(String boardId) async {
    try {
      developer.log('Marquage du board $boardId comme ouvert');
      final now = DateTime.now();
      
      // Mettre à jour dans le stockage local
      await _storageService.saveBoardLastOpened(boardId, now);
      
      // Mettre à jour dans la liste locale
      final index = _boards.indexWhere((board) => board.id == boardId);
      if (index != -1) {
        developer.log("Board trouvé dans la liste locale à l'index $index");
        final updatedBoard = Board(
          id: _boards[index].id,
          name: _boards[index].name,
          desc: _boards[index].desc,
          lastOpened: now,
        );
        _boards[index] = updatedBoard;
        developer.log('Board mis à jour dans la liste locale');
        notifyListeners();
      } else {
        developer.log('Board non trouvé dans la liste locale');
      }

      // Rafraîchir les boards récents (limite à 5)
      final allRecentBoards = await _trelloService.getRecentBoards();
      _recentBoards = allRecentBoards.take(5).toList();
      developer.log('Nombre de boards récents après mise à jour: ${_recentBoards.length}');
      notifyListeners();
    } catch (error) {
      developer.log("Erreur lors de la mise à jour de la date d'ouverture: $error");
      throw Exception("Erreur lors de la mise à jour de la date d'ouverture du board : $error");
    }
  }

  /// **Ajouter un Board avec ou sans template**
Future<bool> addBoard(
  String workspaceId, 
  String boardName, 
  String boardDesc, 
  String? selectedTemplateId, 
  {String? templateId,}
) async {
  try {
    if (templateId != null && templateCards.containsKey(templateId)) {
      // Créer un board AVEC un template local
      final board = await _trelloService.createBoardWithTemplate(
        workspaceId, 
        boardName, 
        boardDesc, 
        templateId,
      );

      if (board != null) {
        // Informer les listeners que l'ajout a eu lieu
        notifyListeners();
        return true; // Assurez-vous de renvoyer un indicateur de succès
      }
    } else {
      // Créer un board SANS template
      final board = await _trelloService.createBoard(
        workspaceId, 
        boardName, 
        boardDesc,
      );

      if (board != null) {
        notifyListeners(); // Notify listeners du changement
        return true;
      }
    }
    return false;
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
        // Mettre à jour le board dans la liste locale
        final index = _boards.indexWhere((board) => board.id == boardId);
        if (index != -1) {
          _boards[index] = Board(
            id: boardId,
            name: newName,
            desc: newDesc,
            lastOpened: _boards[index].lastOpened,
          );
        }
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      developer.log("Chargement des boards depuis l'API");
      _boards = await _trelloService.getBoards();
      developer.log('Nombre de boards récupérés: ${_boards.length}');
      
      // Récupérer les boards récents (limite à 5)
      final allRecentBoards = await _trelloService.getRecentBoards();
      _recentBoards = allRecentBoards.take(5).toList();
      developer.log('Nombre de boards récents: ${_recentBoards.length}');
      
      for (final board in _recentBoards) {
        developer.log('Board récent: ${board.name}, ID: ${board.id}');
      }
    } catch (e) {
      _error = e.toString();
      developer.log('Erreur lors du chargement des boards: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

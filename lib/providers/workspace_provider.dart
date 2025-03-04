import 'package:fluter/models/board.dart';
import 'package:fluter/models/workspace.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:flutter/material.dart';

/// **Classe permettant de gérer les workspaces**
class WorkspaceProvider with ChangeNotifier {

  /// **Constructeur de Workspace**
  WorkspaceProvider({required TrelloService trelloService}) : _trelloService = trelloService;
  final TrelloService _trelloService;

  List<Workspace> _workspaces = <Workspace>[];
  /// **Liste des workspaces**
  List<Workspace> get workspaces => _workspaces;
  List<Board> _workspaceBoards = <Board>[];
  /// **Liste des boards d'un workspace**
  List<Board> get workspaceBoards => _workspaceBoards;

  /// **Récupérer la liste des workspaces**
  Future<List<Workspace>> fetchWorkspaces() async {
    try {
      final List<Map<String, dynamic>> jsonList = await _trelloService.getWorkspaces();
      final workspaces = jsonList.map((json) => Workspace.fromJson(json)).toList();
      _workspaces = workspaces;
      notifyListeners();
      return workspaces;
    } catch (error) {
      throw Exception('Erreur lors de la récupération des workspaces : $error');
    }
  }

  /// **Créer un workspace**
  Future<void> addWorkspace(String name, String displayName, String desc) async {
    final Map<String, dynamic>? newWorkspaceJson = await _trelloService.createWorkspace(name, displayName, desc);
    if (newWorkspaceJson != null) {
      final Workspace newWorkspace = Workspace.fromJson(newWorkspaceJson);
      _workspaces.add(newWorkspace);
      notifyListeners();
    }
  }

  /// **Mettre à jour un workspace**
  Future<void> editWorkspace(String workspaceId, String newDisplayName, String newDesc) async {
    final bool success = await _trelloService.updateWorkspace(workspaceId, newDisplayName, newDesc);
    if (success) {
      final int index = _workspaces.indexWhere((Workspace ws) => ws.id == workspaceId);
      if (index != -1) {
        _workspaces[index] = Workspace(
          id: workspaceId,
          displayName: newDisplayName,
          desc: newDesc,
        );
        notifyListeners();
      }
    }
  }

  /// **Supprimer un workspace**
  Future<void> removeWorkspace(String workspaceId) async {
    final bool success = await _trelloService.deleteWorkspace(workspaceId);
    if (success) {
      _workspaces.removeWhere((Workspace ws) => ws.id == workspaceId);
      notifyListeners();
    }
  }

  /// **Récupérer les boards d'un workspace**
  Future<void> fetchBoardsByWorkspace(String workspaceId) async {
    _workspaceBoards = await _trelloService.getBoardsByWorkspace(workspaceId);
    notifyListeners();
  }
}

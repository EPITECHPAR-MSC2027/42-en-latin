import 'package:fluter/models/board.dart';
import 'package:fluter/models/workspace.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:flutter/material.dart';

class WorkspaceProvider with ChangeNotifier {

  WorkspaceProvider({required TrelloService trelloService}) : _trelloService = trelloService;
  final TrelloService _trelloService;

  List<Workspace> _workspaces = <Workspace>[];
  List<Workspace> get workspaces => _workspaces;
  List<Board> _workspaceBoards = <Board>[];
  List<Board> get workspaceBoards => _workspaceBoards;

  /// **Récupérer la liste des workspaces**
  Future<void> fetchWorkspaces() async {
    final List<Map<String, dynamic>> jsonList = await _trelloService.getWorkspaces();
    _workspaces = jsonList.map(Workspace.fromJson).toList();
    notifyListeners();
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

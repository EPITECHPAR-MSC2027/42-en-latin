import 'package:flutter/material.dart';
import '../services/trello_service.dart';
import '../models/workspace.dart';

class WorkspaceProvider with ChangeNotifier {
  final TrelloService _trelloService;

  List<Workspace> _workspaces = [];
  List<Workspace> get workspaces => _workspaces;

  WorkspaceProvider({required TrelloService trelloService}) : _trelloService = trelloService;

  /// **Récupérer la liste des workspaces**
  Future<void> fetchWorkspaces() async {
    List<Map<String, dynamic>> jsonList = await _trelloService.getWorkspaces();
    _workspaces = jsonList.map((json) => Workspace.fromJson(json)).toList();
    notifyListeners();
  }

  /// **Créer un workspace**
  Future<void> addWorkspace(String name, String displayName, String desc) async {
    final newWorkspaceJson = await _trelloService.createWorkspace(name, displayName, desc);
    if (newWorkspaceJson != null) {
      final newWorkspace = Workspace.fromJson(newWorkspaceJson);
      _workspaces.add(newWorkspace);
      notifyListeners();
    }
  }

  /// **Mettre à jour un workspace**
  Future<void> editWorkspace(String workspaceId, String newDisplayName, String newDesc) async {
    bool success = await _trelloService.updateWorkspace(workspaceId, newDisplayName, newDesc);
    if (success) {
      int index = _workspaces.indexWhere((ws) => ws.id == workspaceId);
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
    bool success = await _trelloService.deleteWorkspace(workspaceId);
    if (success) {
      _workspaces.removeWhere((ws) => ws.id == workspaceId);
      notifyListeners();
    }
  }
}

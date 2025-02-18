import 'package:flutter/material.dart';
import '../services/trello_service.dart';

class WorkspaceProvider with ChangeNotifier {
  final TrelloService _trelloService;

  List<Map<String, dynamic>> _workspaces = [];
  List<Map<String, dynamic>> get workspaces => _workspaces;

  WorkspaceProvider({required TrelloService trelloService}) : _trelloService = trelloService;

  /// **Récupérer la liste des workspaces**
  Future<void> fetchWorkspaces() async {
    _workspaces = await _trelloService.getWorkspaces();
    notifyListeners();
  }

  /// **Créer un workspace**
  Future<void> addWorkspace(String name, String displayName, String desc) async {
    final newWorkspace = await _trelloService.createWorkspace(name, displayName, desc);
    if (newWorkspace != null) {
      _workspaces.add(newWorkspace);
      notifyListeners();
    }
  }

  /// **Mettre à jour un workspace**
  Future<void> editWorkspace(String workspaceId, String newDisplayName, String newDesc) async {
    bool success = await _trelloService.updateWorkspace(workspaceId, newDisplayName, newDesc);
    if (success) {
      int index = _workspaces.indexWhere((ws) => ws['id'] == workspaceId);
      if (index != -1) {
        _workspaces[index]['displayName'] = newDisplayName;
        _workspaces[index]['desc'] = newDesc;
        notifyListeners();
      }
    }
  }

  /// **Supprimer un workspace**
  Future<void> removeWorkspace(String workspaceId) async {
    bool success = await _trelloService.deleteWorkspace(workspaceId);
    if (success) {
      _workspaces.removeWhere((ws) => ws['id'] == workspaceId);
      notifyListeners();
    }
  }
}

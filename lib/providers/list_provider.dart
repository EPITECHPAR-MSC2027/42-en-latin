import 'package:flutter/material.dart';
import '../services/trello_service.dart';
import '../models/list.dart';

class ListProvider with ChangeNotifier {
  final TrelloService _trelloService;
  List<ListModel> _lists = [];

  List<ListModel> get lists => _lists;

  ListProvider({required TrelloService trelloService}) : _trelloService = trelloService;

  /// **Récupérer les listes d'un board**
  Future<void> fetchListsByBoard(String boardId) async {
    try {
      List<Map<String, dynamic>> jsonList = await _trelloService.getListsByBoard(boardId);
      _lists = jsonList.map((json) => ListModel.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la récupération des listes: $e');
    }
  }

  /// **Créer une nouvelle List**
  Future<void> addList(String boardId, String name) async {
    final newList = await _trelloService.createList(boardId, name);
    if (newList != null) {
      _lists.add(newList);
      notifyListeners();
    }
  }

  /// **Mettre à jour une List**
  Future<void> editList(String listId, String newName) async {
    bool success = await _trelloService.updateList(listId, newName);
    if (success) {
      int index = _lists.indexWhere((list) => list.id == listId);
      if (index != -1) {
        _lists[index] = ListModel(id: listId, name: newName);
        notifyListeners();
      }
    }
  }

  /// **Supprimer une List**
  Future<void> removeList(String listId) async {
    bool success = await _trelloService.deleteList(listId);
    if (success) {
      _lists.removeWhere((list) => list.id == listId);
      notifyListeners();
    }
  }
}

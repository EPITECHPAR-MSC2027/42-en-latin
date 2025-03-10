import 'package:fluter/models/list.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:flutter/material.dart';

/// **Classe permettant de gérer les listes**
class ListProvider with ChangeNotifier {


  /// **Constructeur de List**
  ListProvider({required TrelloService trelloService}) : _trelloService = trelloService;
  final TrelloService _trelloService;
  List<ListModel> _lists = <ListModel>[];

  /// **Liste des listes**
  List<ListModel> get lists => _lists;

  /// **Récupérer les listes d'un board**
  Future<void> fetchListsByBoard(String boardId) async {
    final List<Map<String, dynamic>> jsonList = await _trelloService.getListsByBoard(boardId);
    _lists = jsonList.map(ListModel.fromJson).toList();
    notifyListeners();
  }

  /// **Créer une nouvelle List**
  Future<void> addList(String boardId, String name) async {
    final ListModel? newList = await _trelloService.createList(boardId, name);
    if (newList != null) {
      _lists.add(newList);
      notifyListeners();
    }
  }

  /// **Mettre à jour une List**
  Future<void> editList(String listId, String newName) async {
    final bool success = await _trelloService.updateList(listId, newName);
    if (success) {
      final int index = _lists.indexWhere((ListModel list) => list.id == listId);
      if (index != -1) {
        _lists[index] = ListModel(id: listId, name: newName);
        notifyListeners();
      }
    }
  }

  /// **Supprimer une List**
  Future<void> removeList(String listId) async {
    final bool success = await _trelloService.deleteList(listId);
    if (success) {
      _lists.removeWhere((ListModel list) => list.id == listId);
      notifyListeners();
    }
  }
}

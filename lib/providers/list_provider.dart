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
}

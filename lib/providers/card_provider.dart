import 'package:flutter/material.dart';
import '../services/trello_service.dart';
import '../models/card.dart';

class CardProvider with ChangeNotifier {
  final TrelloService _trelloService;
  List<CardModel> _cards = [];

  List<CardModel> get cards => _cards;

  CardProvider({required TrelloService trelloService}) : _trelloService = trelloService;

  /// **Récupérer les cartes d'une liste**
  Future<void> fetchCardsByList(String listId) async {
    try {
      List<Map<String, dynamic>> jsonList = await _trelloService.getCardsByList(listId);
      _cards = jsonList.map((json) => CardModel.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la récupération des cartes: $e');
    }
  }

  /// **Créer une nouvelle carte**
  Future<void> addCard(String listId, String name, String desc) async {
    final newCard = await _trelloService.createCard(listId, name, desc);
    if (newCard != null) {
      _cards.add(CardModel.fromJson(newCard));
      notifyListeners();
    }
  }

  /// **Mettre à jour une carte**
  Future<void> editCard(String cardId, String newName, String newDesc) async {
    bool success = await _trelloService.updateCard(cardId, newName, newDesc);
    if (success) {
      int index = _cards.indexWhere((card) => card.id == cardId);
      if (index != -1) {
        _cards[index] = CardModel(id: cardId, name: newName, desc: newDesc);
        notifyListeners();
      }
    }
  }

  /// **Supprimer une carte**
  Future<void> removeCard(String cardId) async {
    bool success = await _trelloService.deleteCard(cardId);
    if (success) {
      _cards.removeWhere((card) => card.id == cardId);
      notifyListeners();
    }
  }
}

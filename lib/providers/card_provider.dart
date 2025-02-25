import 'package:fluter/models/card.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:flutter/material.dart';

class CardProvider with ChangeNotifier {

  CardProvider({required TrelloService trelloService}) : _trelloService = trelloService;
  final TrelloService _trelloService;
  List<CardModel> _cards = <CardModel>[];

  List<CardModel> get cards => _cards;

  /// **Récupérer les cartes d'une liste**
  Future<void> fetchCardsByList(String listId) async {
    try {
      final List<Map<String, dynamic>> jsonList = await _trelloService.getCardsByList(listId);
      _cards = jsonList.map(CardModel.fromJson).toList();
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la récupération des cartes: $e');
    }
  }

  /// **Créer une nouvelle carte**
  Future<void> addCard(String listId, String name, String desc) async {
    final Map<String, dynamic>? newCard = await _trelloService.createCard(listId, name, desc);
    if (newCard != null) {
      _cards.add(CardModel.fromJson(newCard));
      notifyListeners();
    }
  }

  /// **Mettre à jour une carte**
  Future<void> editCard(String cardId, String newName, String newDesc) async {
    final bool success = await _trelloService.updateCard(cardId, newName, newDesc);
    if (success) {
      final int index = _cards.indexWhere((CardModel card) => card.id == cardId);
      if (index != -1) {
        _cards[index] = CardModel(id: cardId, name: newName, desc: newDesc);
        notifyListeners();
      }
    }
  }

  /// **Supprimer une carte**
  Future<void> removeCard(String cardId) async {
    final bool success = await _trelloService.deleteCard(cardId);
    if (success) {
      _cards.removeWhere((CardModel card) => card.id == cardId);
      notifyListeners();
    }
  }
}

import 'package:fluter/models/card.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:flutter/material.dart';

/// **Classe permettant de gérer les cartes**
class CardProvider with ChangeNotifier {

  /// **Constructeur de Card**
  CardProvider({required TrelloService trelloService}) : _trelloService = trelloService;
  final TrelloService _trelloService;
  List<CardModel> _cards = <CardModel>[];

  /// **Liste des cartes**
  List<CardModel> get cards => _cards;

  /// **Récupérer les cartes d'une liste**
  Future<void> fetchCardsByList(String listId) async {
    final List<Map<String, dynamic>> jsonList = await _trelloService.getCardsByList(listId);
    _cards = jsonList.map(CardModel.fromJson).toList();
    notifyListeners();
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

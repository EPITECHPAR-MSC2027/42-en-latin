import 'dart:io';

import 'package:fluter/models/card.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:flutter/material.dart';

/// **Provider pour gérer les cartes**
class CardProvider with ChangeNotifier {
  CardProvider({required TrelloService trelloService})
    : _trelloService = trelloService;
  final TrelloService _trelloService;
  List<CardModel> _cards = [];

  /// **Liste des cartes**
  List<CardModel> get cards => _cards;

  /// **Récupérer toutes les cartes d'un board**
  Future<void> fetchCardsByBoard(String boardId) async {
    final List<Map<String, dynamic>> jsonList = await _trelloService
        .getCardsByBoard(boardId);
    _cards = jsonList.map(CardModel.fromJson).toList();
    notifyListeners();
  }

  /// **Récupérer les cartes d'une liste spécifique**
  List<CardModel> fetchCardsByList(String listId) {
    return _cards.where((card) => card.listId == listId).toList();
  }

  /// **Créer une nouvelle carte**
  Future<void> addCard(
    String listId,
    String name,
    String desc, {
    File? imageFile,
  }) async {
    final Map<String, dynamic>? newCard = await _trelloService.createCard(
      listId,
      name,
      desc,
    );
    if (newCard != null) {
      // Créez la carte initialement
      CardModel card = CardModel.fromJson(newCard);

      // Si une image est fournie, essayez de l'attacher
      if (imageFile != null) {
        final bool attachmentSuccess = await _trelloService.attachImageToCard(
          card.id,
          imageFile,
        );
        if (attachmentSuccess) {
          // Récupérer l'URL mise à jour après l'ajout de l'image
          final String? newImageUrl = await _trelloService.getImageUrlForCard(
            card.id,
          );
          if (newImageUrl != null) {
            card = card.copyWith(imageUrl: newImageUrl);
          }
        }
      }
      // Ajoutez la carte mise à jour à la liste locale et notifiez les listeners
      _cards.add(card);
      notifyListeners();
    }
  }

  /// **Mettre à jour une carte**
  /// **Mettre à jour une carte**
  Future<void> editCard(
    String cardId,
    String newName,
    String newDesc, {
    File? imageFile,
  }) async {
    final bool success = await _trelloService.updateCard(
      cardId,
      newName,
      newDesc,
    );
    if (success) {
      final int index = _cards.indexWhere(
        (CardModel card) => card.id == cardId,
      );
      if (index != -1) {
        CardModel updatedCard = _cards[index].copyWith(
          name: newName,
          desc: newDesc,
        );
        if (imageFile != null) {
          // Attacher la nouvelle image
          final bool attachmentSuccess = await _trelloService.attachImageToCard(
            cardId,
            imageFile,
          );
          if (attachmentSuccess) {
            // Récupérer l'URL mise à jour après l'ajout de l'image
            final String? newImageUrl = await _trelloService.getImageUrlForCard(
              cardId,
            );
            if (newImageUrl != null) {
              updatedCard = updatedCard.copyWith(imageUrl: newImageUrl);
            }
          }
        }
        _cards[index] = updatedCard;
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

  /// **Déplacer une carte d'une liste à une autre**
  Future<void> moveCardToList(String cardId, String newListId) async {
    final bool success = await _trelloService.updateCardList(cardId, newListId);
    if (success) {
      final int cardIndex = _cards.indexWhere((card) => card.id == cardId);
      if (cardIndex != -1) {
        _cards[cardIndex] = _cards[cardIndex].copyWith(listId: newListId);
        notifyListeners();
      }
    }
  }
}

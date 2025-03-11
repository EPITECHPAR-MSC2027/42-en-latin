import 'package:fluter/models/favorite.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider({required this.trelloService});

  final TrelloService trelloService;
  List<Favorite> _favorites = [];

  List<Favorite> get favorites => _favorites;

  Future<void> loadFavorites() async {
    try {
      final favoritesData = await trelloService.getFavorites();
      _favorites = favoritesData.map((json) => Favorite.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement des favoris: $e');
    }
  }
} 
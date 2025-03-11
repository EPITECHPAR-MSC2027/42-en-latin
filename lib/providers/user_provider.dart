import 'package:fluter/models/user.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({required this.trelloService});

  final TrelloService trelloService;
  TrelloUser? _user;

  TrelloUser? get user => _user;

  Future<void> loadUserInfo() async {
    try {
      final userData = await trelloService.getUserInfo();
      _user = TrelloUser.fromJson(userData);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement des informations utilisateur: $e');
    }
  }
}

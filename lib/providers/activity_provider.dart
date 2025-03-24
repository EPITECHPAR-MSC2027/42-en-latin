import 'package:fluter/models/activity.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:flutter/material.dart';

class ActivityProvider with ChangeNotifier {

  ActivityProvider({required this.trelloService});
  final TrelloService trelloService;
  List<Activity> _activities = [];

  List<Activity> get activities => _activities;
  
  // Getter pour récupérer seulement les 5 activités les plus récentes
  List<Activity> get recentActivities {
    // On trie d'abord par date (plus récent en premier)
    final sorted = List<Activity>.from(_activities)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // On retourne les 5 premières ou moins s'il y en a moins de 5
    return sorted.take(5).toList();
  }

  Future<void> loadRecentActivities() async {
    final List<Map<String, dynamic>> activitiesJson = await trelloService.getRecentActivities();
    _activities = activitiesJson.map(Activity.fromJson).toList();
    notifyListeners();
  }
}

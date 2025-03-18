import 'package:fluter/models/activity.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:flutter/material.dart';

class ActivityProvider with ChangeNotifier {

  ActivityProvider({required this.trelloService});
  final TrelloService trelloService;
  List<Activity> _activities = [];

  List<Activity> get activities => _activities;

  Future<void> loadRecentActivities() async {
    final List<Map<String, dynamic>> activitiesJson = await trelloService.getRecentActivities();
    _activities = activitiesJson.map(Activity.fromJson).toList();
    notifyListeners();
  }
} 

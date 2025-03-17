import 'package:flutter/material.dart';
import 'package:fluter/services/trello_service.dart';
import 'package:fluter/models/activity.dart';

class ActivityProvider with ChangeNotifier {
  final TrelloService trelloService;
  List<Activity> _activities = [];

  ActivityProvider({required this.trelloService});

  List<Activity> get activities => _activities;

  Future<void> loadRecentActivities() async {
    final List<Map<String, dynamic>> activitiesJson = await trelloService.getRecentActivities();
    _activities = activitiesJson.map((json) => Activity.fromJson(json)).toList();
    notifyListeners();
  }
} 
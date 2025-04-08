import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour gérer le stockage local des données
class StorageService {
  /// Clé pour stocker les dates de dernière ouverture des boards
  static const String _lastOpenedKey = 'board_last_opened';

  /// Sauvegarder la date de dernière ouverture d'un board
  Future<void> saveBoardLastOpened(String boardId, DateTime date) async {
    developer.log("Sauvegarde de la date d'ouverture pour le board $boardId: ${date.toIso8601String()}");
    
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> lastOpenedMap = {};
    
    // Récupérer les données existantes
    final String? existingData = prefs.getString(_lastOpenedKey);
    if (existingData != null) {
      lastOpenedMap.addAll(json.decode(existingData) as Map<String, dynamic>);
      developer.log('Données existantes: $existingData');
    }
    
    // Mettre à jour la date pour ce board
    lastOpenedMap[boardId] = date.toIso8601String();
    
    // Sauvegarder les données mises à jour
    final String jsonData = json.encode(lastOpenedMap);
    developer.log('Données sauvegardées: $jsonData');
    await prefs.setString(_lastOpenedKey, jsonData);
  }

  /// Récupérer la date de dernière ouverture d'un board
  Future<DateTime?> getBoardLastOpened(String boardId) async {
    developer.log("Récupération de la date d'ouverture pour le board $boardId");
    
    final prefs = await SharedPreferences.getInstance();
    final String? existingData = prefs.getString(_lastOpenedKey);
    
    if (existingData != null) {
      developer.log('Données récupérées: $existingData');
      final Map<String, dynamic> lastOpenedMap = json.decode(existingData) as Map<String, dynamic>;
      if (lastOpenedMap.containsKey(boardId)) {
        final date = DateTime.parse(lastOpenedMap[boardId] as String);
        developer.log('Date trouvée: ${date.toIso8601String()}');
        return date;
      }
    }
    
    developer.log('Aucune date trouvée pour le board $boardId');
    return null;
  }

  /// Récupérer toutes les dates de dernière ouverture des boards
  Future<Map<String, DateTime>> getAllBoardsLastOpened() async {
    developer.log("Récupération de toutes les dates d'ouverture");
    
    final prefs = await SharedPreferences.getInstance();
    final String? existingData = prefs.getString(_lastOpenedKey);
    
    if (existingData != null) {
      developer.log('Données récupérées: $existingData');
      final Map<String, dynamic> lastOpenedMap = json.decode(existingData) as Map<String, dynamic>;
      final result = lastOpenedMap.map((key, value) => MapEntry(key, DateTime.parse(value as String)));
      developer.log("Nombre de boards avec date d'ouverture: ${result.length}");
      return result;
    }
    
    developer.log('Aucune donnée trouvée');
    return {};
  }
} 

import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Couleurs par défaut (Original)
  Color _beige = const Color(0xFFFFEDE3);
  Color _vertGris = const Color(0xFFC0CCC9);
  Color _vertText = const Color(0xFF314A43);
  Color _blanc = const Color(0xFFFFFFFF);
  Color _grisClair = const Color(0xFFE0E0E0);
  Color _vert = const Color(0xFF4CAF50);
  Color _rouge = const Color(0xFFE57373);
  Color _vertSucces = const Color(0xFF81C784);
  Color _orange = const Color(0xFFFFB74D);

  // Getters pour les couleurs
  Color get beige => _beige;
  Color get vertGris => _vertGris;
  Color get vertText => _vertText;
  Color get blanc => _blanc;
  Color get grisClair => _grisClair;
  Color get vert => _vert;
  Color get rouge => _rouge;
  Color get vertSucces => _vertSucces;
  Color get orange => _orange;

  void setTheme(String themeName) {
    switch (themeName) {
      case 'Original':
        _beige = const Color(0xFFFFEDE3);
        _vertGris = const Color(0xFFC0CCC9);
        _vertText = const Color(0xFF314A43);
        _blanc = const Color(0xFFFFFFFF);
        _grisClair = const Color(0xFFE0E0E0);
        _vert = const Color(0xFF4CAF50);
        _rouge = const Color(0xFFE57373);
        _vertSucces = const Color(0xFF81C784);
        _orange = const Color(0xFFFFB74D);
        break;
      case 'Bubble':
        _beige = const Color(0xFFD5E2F0);
        _vertGris = const Color(0xFFE39DB9);
        _vertText = const Color(0xFF90B57D);
        _blanc = const Color(0xFFFFF5F7);
        _grisClair = const Color(0xFFE6B3B3);
        _vert = const Color(0xFF5699A9);
        _rouge = const Color(0xFFE57373);
        _vertSucces = const Color(0xFF81C784);
        _orange = const Color(0xFFFFB74D);
        break;
      case 'Starry Night':
        _beige = const Color(0xFF1B0E6A);
        _vertGris = const Color(0xFFBF8CE1);
        _vertText = Colors.white;
        _blanc = const Color(0xFF4A90E2);
        _grisClair = const Color(0xFFABC8FF);
        _vert = const Color(0xFFABC8FF);
        _rouge = const Color(0xFFE57373);
        _vertSucces = const Color(0xFF81C784);
        _orange = const Color(0xFFFFB74D);
        break;
    }
    notifyListeners();
  }
}

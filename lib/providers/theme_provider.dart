import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  Color _beige = const Color(0xFFFFEDE3);
  Color _vertGris = const Color(0xFFC0CCC9);
  Color _vertText = const Color(0xFF314A43);
  Color _blanc = const Color(0xFFFFFFFF);
  Color _grisClair = const Color(0xFFE0E0E0);
  Color _vert = const Color(0xFF4CAF50);
  Color _rouge = const Color(0xFFC27C88);
  Color _vertSucces = const Color(0xFF81C784);
  Color _orange = const Color(0xFFFFB74D);
  Color _bleuClair = const Color(0xFFC9d2e3);
  Color _vertfavorite = const Color(0xFF879596);

  // Getters
  Color get beige => _beige;
  Color get vertGris => _vertGris;
  Color get vertText => _vertText;
  Color get blanc => _blanc;
  Color get grisClair => _grisClair;
  Color get vert => _vert;
  Color get rouge => _rouge;
  Color get vertSucces => _vertSucces;
  Color get orange => _orange;
  Color get bleuClair => _bleuClair;
  Color get vertfavorite => _vertfavorite;

  void setTheme(String themeName) {
    switch (themeName) {
      case 'Original':
        _beige = const Color(0xFFFFEDE3);
        _vertGris = const Color(0xFFC0CCC9);
        _vertText = const Color(0xFF314A43);
        _blanc = const Color(0xFFFFFFFF);
        _grisClair = const Color(0xFFE0E0E0);
        _vert = const Color(0xFF4CAF50);
        _rouge = const Color(0xFFC27C88);
        _vertSucces = const Color(0xFF81C784);
        _orange = const Color(0xFFFFB74D);
        _bleuClair = const Color(0xFFC9d2e3);
        _vertfavorite = const Color(0xFF879596);
        break;
      case 'Bubble':
        _beige = const Color(0xFFfedce1);
        _vertGris = const Color(0xFFD5E2F0);
        _vertText = const Color(0xFF5699A9);
        _blanc = const Color(0xFFFFF5F7);
        _grisClair = const Color(0xFFE6B3B3);
        _vert = const Color(0xFFD5E2F0);
        _rouge = const Color(0xFFE39DB9);
        _vertSucces = const Color(0xFF81C784);
        _orange = const Color(0xFFFFB74D);
        _bleuClair = const Color(0xFFfef2dc);
        _vertfavorite = const Color(0xFF94836b);
        break;
      case 'Starry Night':
        _beige = const Color(0xFF1B0E6A);
        _vertGris = const Color(0xFFaa6ad2);
        _vertText = const Color(0xFFADC6E5);
        _blanc = const Color(0xFF4A90E2);
        _grisClair = const Color(0xFFABC8FF);
        _vert = const Color(0xFFABC8FF);
        _rouge = const Color(0xFFADC6E5);
        _vertSucces = const Color(0xFF81C784);
        _orange = const Color(0xFFFFB74D);
        _bleuClair = const Color(0xFF1c1dab);
        _vertfavorite = const Color(0xFFebb2c3);

        break;
    }
    notifyListeners();
  }
}

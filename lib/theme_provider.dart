import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  // Getter pour accéder à l'état du mode sombre
  bool get isDarkMode => _isDarkMode;

  // Méthode pour basculer le thème
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Notifie les auditeurs pour appliquer le changement de thème
  }

  // Retourne le ThemeData en fonction du mode sombre
  ThemeData get themeData {
    return _isDarkMode ? ThemeData.dark() : ThemeData.light();
  }
}

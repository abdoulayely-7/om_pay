import 'package:flutter/material.dart';

extension RouterExtension on BuildContext {
  // Routes principales
  void goToAccueil() => Navigator.pushNamed(this, '/');

  void goToLogin() => Navigator.pushNamed(this, '/login');

  void goToHome() => Navigator.pushReplacementNamed(this, '/home');

  void goBack() => Navigator.pop(this);

  // Navigation avec remplacement (pour auth)
  void replaceWithLogin() => Navigator.pushReplacementNamed(this, '/login');

  void replaceWithHome() => Navigator.pushReplacementNamed(this, '/home');

  // Navigation qui vide la pile
  void goToHomeAndClearStack() {
    Navigator.pushNamedAndRemoveUntil(
      this,
      '/home',
      (route) => false
    );
  }

  // Récupération d'arguments
  T? getArguments<T>() {
    return ModalRoute.of(this)?.settings.arguments as T?;
  }
}
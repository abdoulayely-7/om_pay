# Guide du Routage avec Extensions Dart

## Introduction

Les **extensions** sont une fonctionnalité puissante de Dart qui permet d'ajouter des méthodes à des classes existantes sans les modifier. Dans le contexte du routage Flutter, les extensions permettent de créer des méthodes de navigation propres et maintenables.

## Qu'est-ce qu'une Extension ?

### Définition

Une extension permet d'ajouter des méthodes et propriétés à une classe existante :

```dart
extension MaExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

// Utilisation
String nom = 'john';
print(nom.capitalize()); // 'John'
```

### Syntaxe

```dart
extension NomExtension on TypeCible {
  // Propriétés et méthodes à ajouter
  TypeRetour nomMethode(parametres) {
    // Implementation
  }
}
```

## Extensions pour le Routage

### Pourquoi utiliser des extensions pour le routage ?

#### ✅ **Avantages**

1. **Lisibilité** : `context.goToHome()` vs `Navigator.pushReplacementNamed(context, '/home')`
2. **Autocomplétion** : L'IDE propose automatiquement les méthodes
3. **Maintenance** : Changements centralisés dans l'extension
4. **Type safety** : Méthodes liées au BuildContext
5. **Réutilisabilité** : Disponible partout dans l'app

#### ❌ **Inconvénients**

1. **Découplage** : Cache la logique Navigator
2. **Dépendance** : Nécessite l'import de l'extension

### Implémentation dans votre projet

#### 1. Création de l'extension

```dart
// lib/router/router_extension.dart
import 'package:flutter/material.dart';

extension RouterExtension on BuildContext {
  // Navigation de base
  void goToAccueil() => Navigator.pushNamed(this, '/');

  void goToLogin() => Navigator.pushNamed(this, '/login');

  void goToHome() => Navigator.pushReplacementNamed(this, '/home');

  // Navigation avec remplacement
  void replaceWithLogin() => Navigator.pushReplacementNamed(this, '/login');

  void replaceWithHome() => Navigator.pushReplacementNamed(this, '/home');

  // Navigation spéciale
  void goToHomeAndClearStack() {
    Navigator.pushNamedAndRemoveUntil(
      this,
      '/home',
      (route) => false
    );
  }

  // Retour
  void goBack() => Navigator.pop(this);

  // Récupération d'arguments
  T? getArguments<T>() {
    return ModalRoute.of(this)?.settings.arguments as T?;
  }
}
```

#### 2. Import dans les fichiers

```dart
// Dans chaque écran qui utilise la navigation
import '../router/router_extension.dart';
```

#### 3. Utilisation

```dart
class AccueilScreen extends StatefulWidget {
  @override
  _AccueilScreenState createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  Future<void> _checkAuthAndNavigate() async {
    final token = await _getToken();

    if (token != null) {
      context.goToHome();  // ✨ Extension
    } else {
      context.goToLogin(); // ✨ Extension
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.goBack(), // ✨ Extension
          child: Text('Retour'),
        ),
      ),
    );
  }
}
```

## Comparaison avec les approches traditionnelles

### Avant (sans extension)

```dart
// Dans AccueilScreen
if (token != null) {
  Navigator.pushReplacementNamed(context, '/home');
} else {
  Navigator.pushReplacementNamed(context, '/login');
}

// Dans LoginScreen
Navigator.pushReplacementNamed(context, '/home');

// Dans HomeScreen
Navigator.pushReplacementNamed(context, '/login');
Navigator.pop(context);
```

### Après (avec extension)

```dart
// Dans AccueilScreen
if (token != null) {
  context.goToHome();
} else {
  context.goToLogin();
}

// Dans LoginScreen
context.goToHome();

// Dans HomeScreen
context.replaceWithLogin();
context.goBack();
```

## Fonctionnalités avancées

### Arguments typés

```dart
extension RouterExtension on BuildContext {
  void goToUserProfile(String userId) {
    Navigator.pushNamed(
      this,
      '/user',
      arguments: userId,
    );
  }

  void goToProductDetail(String productId, {bool isEditing = false}) {
    Navigator.pushNamed(
      this,
      '/product',
      arguments: {
        'id': productId,
        'isEditing': isEditing,
      },
    );
  }
}

// Utilisation
context.goToUserProfile('123');
context.goToProductDetail('456', isEditing: true);
```

### Guards et validation

```dart
extension RouterExtension on BuildContext {
  void goToProtectedRoute() {
    // Vérifier l'authentification
    final hasToken = _checkToken();
    if (hasToken) {
      Navigator.pushNamed(this, '/protected');
    } else {
      goToLogin();
    }
  }

  void goToAdminPanel() {
    // Vérifier les permissions
    final isAdmin = _checkAdminRole();
    if (isAdmin) {
      Navigator.pushNamed(this, '/admin');
    } else {
      // Afficher message d'erreur
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(content: Text('Accès refusé')),
      );
    }
  }
}
```

### Animations personnalisées

```dart
extension RouterExtension on BuildContext {
  void goToScreenWithAnimation(Widget screen) {
    Navigator.push(
      this,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}
```

## Bonnes pratiques

### 1. Nommage cohérent

```dart
// ✅ Bon
void goToHome()
void goToLogin()
void goToSettings()

// ❌ Mauvais
void navigateToHome()
void pushHome()
void home()
```

### 2. Grouper par fonctionnalité

```dart
extension AuthRouter on BuildContext {
  void goToLogin() => Navigator.pushNamed(this, '/login');
  void goToRegister() => Navigator.pushNamed(this, '/register');
  void goToForgotPassword() => Navigator.pushNamed(this, '/forgot');
}

extension MainRouter on BuildContext {
  void goToHome() => Navigator.pushReplacementNamed(this, '/home');
  void goToProfile() => Navigator.pushNamed(this, '/profile');
  void goToSettings() => Navigator.pushNamed(this, '/settings');
}
```

### 3. Gestion d'erreurs

```dart
extension SafeRouter on BuildContext {
  void safeGoBack() {
    if (Navigator.canPop(this)) {
      Navigator.pop(this);
    } else {
      // Navigation vers écran par défaut
      goToHome();
    }
  }
}
```

### 4. Logging et analytics

```dart
extension AnalyticsRouter on BuildContext {
  void goToScreenWithAnalytics(String routeName) {
    // Log l'événement
    AnalyticsService.logNavigation(routeName);

    // Navigation normale
    Navigator.pushNamed(this, routeName);
  }
}
```

## Architecture recommandée

### Structure de fichiers

```
lib/
├── router/
│   ├── router_extension.dart      # Extensions principales
│   ├── auth_router.dart           # Extensions auth
│   └── feature_router.dart        # Extensions features
├── screens/
│   ├── auth/
│   ├── home/
│   └── ...
└── main.dart
```

### Utilisation dans main.dart

```dart
// main.dart garde la définition des routes
MaterialApp(
  routes: {
    '/': (context) => const AccueilScreen(),
    '/login': (context) => const LoginScreen(),
    '/home': (context) => const HomeScreen(),
  },
)

// Les écrans utilisent les extensions
class AccueilScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.goToLogin(),
      child: Text('Connexion'),
    );
  }
}
```

## Migration depuis Navigator direct

### Étape 1 : Créer l'extension

```dart
extension RouterExtension on BuildContext {
  void goToHome() => Navigator.pushReplacementNamed(this, '/home');
  void goToLogin() => Navigator.pushNamed(this, '/login');
}
```

### Étape 2 : Remplacer progressivement

```dart
// Avant
Navigator.pushNamed(context, '/login');

// Après
context.goToLogin();
```

### Étape 3 : Ajouter les imports

```dart
import '../router/router_extension.dart';
```

## Avantages pour les équipes

### Développement collaboratif

- **Cohérence** : Toutes les navigations utilisent les mêmes méthodes
- **Révision** : Changements de routage centralisés
- **Documentation** : Les extensions servent de documentation vivante

### Maintenance

- **Refactoring** : Changer une route dans l'extension affecte toute l'app
- **Debugging** : Points d'entrée uniques pour la navigation
- **Testing** : Facile de mocker les extensions

## Alternatives

### 1. GoRouter (recommandé pour gros projets)

```dart
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
  ],
);

// Navigation
context.go('/home');
```

### 2. Provider + NavigationService

```dart
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void goToHome() => navigatorKey.currentState?.pushNamed('/home');
}
```

### 3. BLoC + Navigation

```dart
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  @override
  Stream<NavigationState> mapEventToState(NavigationEvent event) async* {
    if (event is NavigateToHome) {
      navigatorKey.currentState?.pushNamed('/home');
    }
  }
}
```

## Conclusion

Les extensions Dart offrent une approche élégante et maintenable pour le routage Flutter. Elles améliorent la lisibilité du code, facilitent la maintenance et fournissent une meilleure expérience développeur grâce à l'autocomplétion.

Pour votre projet OM Pay, l'extension `RouterExtension` centralise toute la logique de navigation, rendant le code plus propre et évolutif.

**Points clés :**
- Extensions = méthodes ajoutées à des classes existantes
- `RouterExtension on BuildContext` = navigation propre
- Centralisation = maintenance facile
- Type safety = moins d'erreurs
- Autocomplétion = développement rapide
# Guide GoRouter pour Flutter

## Introduction

GoRouter est le package de routage officiel recommandé par Google pour Flutter. Il offre un système de routage déclaratif, moderne et puissant qui remplace avantageusement le système traditionnel de Flutter.

## Installation

```yaml
dependencies:
  go_router: ^14.0.0
```

## Configuration de base

### 1. Création du router

```dart
// lib/router/app_router.dart
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
  ],
);
```

### 2. Configuration dans main.dart

```dart
// main.dart
import 'package:flutter/material.dart';
import 'router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OM Pay',
      theme: ThemeData.dark(),
      routerConfig: appRouter, // Configuration du router
    );
  }
}
```

## Navigation avec GoRouter

### Navigation simple

```dart
// Aller vers une route
context.go('/login');

// Navigation avec remplacement (pas de retour possible)
context.go('/home');

// Retour en arrière
context.pop();

// Navigation avec paramètres
context.go('/user/123');

// Navigation nommée avec paramètres
context.goNamed('user', params: {'id': '123'});
```

### Différences avec Navigator

| Action | Navigator | GoRouter |
|--------|-----------|----------|
| Aller vers | `pushNamed(context, '/login')` | `context.go('/login')` |
| Remplacer | `pushReplacementNamed(context, '/home')` | `context.go('/home')` |
| Retour | `pop(context)` | `context.pop()` |
| Params | `arguments: data` | `extra: data` ou URL params |

## Routes avec paramètres

### 1. Paramètres dans l'URL

```dart
final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/user/:id',
      builder: (context, state) {
        final userId = state.pathParameters['id']!;
        return UserScreen(userId: userId);
      },
    ),
  ],
);

// Navigation
context.go('/user/123');
```

### 2. Paramètres query

```dart
GoRoute(
  path: '/search',
  builder: (context, state) {
    final query = state.uri.queryParameters['q'] ?? '';
    return SearchScreen(query: query);
  },
)

// Navigation
context.go('/search?q=flutter');
```

### 3. Paramètres extra

```dart
GoRoute(
  path: '/user',
  builder: (context, state) {
    final user = state.extra as User?;
    return UserScreen(user: user);
  },
)

// Navigation
context.go('/user', extra: user);
```

## Redirections et Guards

### Redirections automatiques

```dart
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = _checkAuthStatus();

    // Redirection vers login si pas connecté
    if (!isLoggedIn && state.uri.path != '/login') {
      return '/login';
    }

    // Redirection vers home si déjà connecté
    if (isLoggedIn && state.uri.path == '/login') {
      return '/';
    }

    return null; // Pas de redirection
  },
  routes: [/* routes */],
);
```

### Guards sur les routes

```dart
GoRoute(
  path: '/admin',
  builder: (context, state) => AdminScreen(),
  redirect: (context, state) {
    final isAdmin = _checkAdminRole();
    return isAdmin ? null : '/'; // Redirige si pas admin
  },
)
```

## Routes imbriquées (Nested Navigation)

### BottomNavigationBar avec GoRouter

```dart
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeTab(),
          SearchTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

## Gestion des erreurs

### Route inconnue

```dart
final GoRouter appRouter = GoRouter(
  errorBuilder: (context, state) {
    return ErrorScreen(error: state.error);
  },
  routes: [/* routes */],
);
```

### Page 404 personnalisée

```dart
GoRoute(
  path: '/404',
  builder: (context, state) => NotFoundScreen(),
)
```

## Transitions et animations

### Transitions personnalisées

```dart
GoRoute(
  path: '/details',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: DetailsScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ),
)
```

## Deep Linking

### Configuration pour le web

```dart
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [/* routes */],
  // Support du deep linking
  urlPathStrategy: UrlPathStrategy.path, // Supprime le # dans l'URL
);
```

### Gestion des URLs entrantes

```dart
// Dans main.dart
void main() {
  // Gérer les URLs quand l'app est fermée
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}
```

## Intégration avec votre projet OM Pay

### Configuration actuelle

```dart
// lib/router/app_router.dart
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AccueilScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);

// main.dart
MaterialApp.router(
  routerConfig: appRouter,
  theme: AppTheme.darkTheme,
)
```

### Navigation dans les écrans

```dart
// AccueilScreen
if (token != null) {
  context.go('/home');
} else {
  context.go('/login');
}

// LoginScreen
context.go('/home');

// HomeScreen
context.go('/');
```

## Avantages de GoRouter

### ✅ **Fonctionnalités avancées**
- Deep linking natif
- Gestion d'historique
- Redirections déclaratives
- Support des paramètres complexes

### ✅ **Performance**
- Lazy loading des routes
- Cache intelligent
- Transitions fluides

### ✅ **Maintenabilité**
- Code déclaratif
- Tests faciles
- Debugging avancé

### ✅ **Évolutivité**
- Support des gros projets
- Architecture modulaire
- Intégration facile

## Migration depuis Navigator

### Étape 1 : Installation
```bash
flutter pub add go_router
```

### Étape 2 : Création du router
```dart
final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
  ],
);
```

### Étape 3 : Modification de main.dart
```dart
MaterialApp.router(
  routerConfig: appRouter,
)
```

### Étape 4 : Remplacement des navigations
```dart
// Avant
Navigator.pushNamed(context, '/login');

// Après
context.go('/login');
```

## Bonnes pratiques

### 1. Structure des fichiers

```
lib/
├── router/
│   ├── app_router.dart      # Configuration principale
│   ├── guards.dart          # Logique de redirection
│   └── transitions.dart     # Animations personnalisées
├── screens/
├── widgets/
└── main.dart
```

### 2. Nommage des routes

```dart
class RouteNames {
  static const home = '/';
  static const login = '/login';
  static const profile = '/profile';
  static const settings = '/settings';
}

// Utilisation
context.go(RouteNames.login);
```

### 3. Gestion des états

```dart
class AuthGuard extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
```

### 4. Tests

```dart
void main() {
  testWidgets('Navigation test', (tester) async {
    await tester.pumpWidget(MyApp());

    // Tester la navigation
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Login Screen'), findsOneWidget);
  });
}
```

## Conclusion

GoRouter apporte une approche moderne et puissante au routage Flutter. Il est particulièrement adapté pour :

- Applications complexes avec beaucoup d'écrans
- Applications nécessitant du deep linking
- Équipes travaillant sur des projets à long terme
- Applications avec des exigences de navigation avancées

Pour votre projet OM Pay, GoRouter offre une base solide pour l'évolutivité future tout en gardant la simplicité actuelle.

**Points clés :**
- Configuration déclarative
- Navigation avec `context.go()`
- Support avancé des paramètres
- Deep linking et redirections
- Performance et maintenabilité
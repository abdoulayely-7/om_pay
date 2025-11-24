# Guide du Routage avec Flutter

## Introduction

Le routage dans Flutter permet de naviguer entre différentes pages (screens) de votre application. Flutter utilise le concept de routes pour gérer la navigation.

## Configuration de base

### 1. MaterialApp avec routes

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon App',
      initialRoute: '/',  // Route de départ
      routes: {
        '/': (context) => HomeScreen(),      // Route racine
        '/login': (context) => LoginScreen(), // Route de connexion
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
```

### 2. Navigation simple

```dart
// Aller vers une route
Navigator.pushNamed(context, '/login');

// Remplacer la route actuelle
Navigator.pushReplacementNamed(context, '/home');

// Retourner en arrière
Navigator.pop(context);
```

## Routes nommées

### Définition des routes

```dart
routes: {
  '/home': (context) => HomeScreen(),
  '/user': (context) => UserScreen(),
  '/settings': (context) => SettingsScreen(),
}
```

### Navigation

```dart
// Navigation simple
Navigator.pushNamed(context, '/user');

// Avec remplacement (pas de retour possible)
Navigator.pushReplacementNamed(context, '/login');

// Retour à la page précédente
Navigator.pop(context);

// Retour à la racine
Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
```

## Passage d'arguments

### Méthode 1: Arguments dans pushNamed

```dart
// Navigation avec arguments
Navigator.pushNamed(
  context,
  '/user',
  arguments: {'userId': 123, 'name': 'John'},
);
```

### Récupération des arguments

```dart
class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Récupération des arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final userId = args['userId'];
    final name = args['name'];

    return Scaffold(
      appBar: AppBar(title: Text('User: $name')),
      body: Center(child: Text('ID: $userId')),
    );
  }
}
```

### Méthode 2: onGenerateRoute (pour arguments typés)

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/user') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => UserScreen(
              userId: args['userId'],
              name: args['name'],
            ),
          );
        }
        return null;
      },
    );
  }
}
```

## Navigation avec état

### Stateful navigation

```dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _navigateToUser() {
    Navigator.pushNamed(context, '/user').then((result) {
      // Callback après retour de la page
      if (result != null) {
        setState(() {
          // Mettre à jour l'état
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _navigateToUser,
          child: Text('Voir utilisateur'),
        ),
      ),
    );
  }
}
```

## Gestion des erreurs de route

### Route inconnue

```dart
onUnknownRoute: (settings) {
  return MaterialPageRoute(
    builder: (context) => UnknownScreen(),
  );
}
```

## Transitions personnalisées

### Route avec transition

```dart
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => UserScreen(),
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
```

## Navigation imbriquée (Nested Navigation)

### Avec BottomNavigationBar

```dart
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeTab(),
    SearchTab(),
    ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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

## Gestion du back button

### Override du back button

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Logique personnalisée avant de quitter
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Quitter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Non'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Oui'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('My Screen')),
        body: Center(child: Text('Contenu')),
      ),
    );
  }
}
```

## Bonnes pratiques

### 1. Nommage des routes

```dart
class RouteNames {
  static const home = '/';
  static const login = '/login';
  static const profile = '/profile';
  static const settings = '/settings';
}
```

### 2. Séparation des responsabilités

```dart
// routes.dart
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      default:
        return MaterialPageRoute(builder: (_) => UnknownScreen());
    }
  }
}

// main.dart
MaterialApp(
  onGenerateRoute: AppRouter.generateRoute,
)
```

### 3. Gestion des arguments typés

```dart
class UserArguments {
  final int userId;
  final String name;

  UserArguments({required this.userId, required this.name});
}

// Navigation
Navigator.pushNamed(
  context,
  '/user',
  arguments: UserArguments(userId: 123, name: 'John'),
);

// Récupération
final args = ModalRoute.of(context)!.settings.arguments as UserArguments;
```

## Exemple complet

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/second': (context) => SecondScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/user') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => UserScreen(
              userId: args['userId'],
              name: args['name'],
            ),
          );
        }
        return null;
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/second'),
              child: Text('Aller à Second Screen'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                '/user',
                arguments: {'userId': 123, 'name': 'John'},
              ),
              child: Text('Voir User'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Second Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Retour'),
        ),
      ),
    );
  }
}

class UserScreen extends StatelessWidget {
  final int userId;
  final String name;

  UserScreen({required this.userId, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User: $name')),
      body: Center(
        child: Text('ID: $userId'),
      ),
    );
  }
}
```

## Conclusion

Le système de routage de Flutter est flexible et puissant. Commencez simple avec les routes nommées, puis ajoutez des arguments et des transitions personnalisées selon vos besoins. Utilisez `onGenerateRoute` pour les routes dynamiques et `ModalRoute.of(context)` pour récupérer les arguments.
# Guide SharedPreferences avec Flutter

## Introduction

SharedPreferences est un package Flutter qui permet de stocker des données simples de manière persistante sur l'appareil. Il est particulièrement utile pour sauvegarder des préférences utilisateur, des tokens d'authentification, ou des paramètres d'application.

## Installation

Ajoutez la dépendance dans votre `pubspec.yaml` :

```yaml
dependencies:
  shared_preferences: ^2.2.3
```

Puis exécutez `flutter pub get`.

## Import

```dart
import 'package:shared_preferences/shared_preferences.dart';
```

## Utilisation de base

### 1. Obtenir une instance

```dart
final SharedPreferences prefs = await SharedPreferences.getInstance();
```

### 2. Stocker des données

```dart
// String
await prefs.setString('username', 'john_doe');

// Int
await prefs.setInt('age', 25);

// Bool
await prefs.setBool('isLoggedIn', true);

// Double
await prefs.setDouble('height', 1.75);

// List<String>
await prefs.setStringList('favorites', ['apple', 'banana', 'orange']);
```

### 3. Récupérer des données

```dart
// String
String? username = prefs.getString('username');

// Int
int? age = prefs.getInt('age');

// Bool
bool? isLoggedIn = prefs.getBool('isLoggedIn');

// Double
double? height = prefs.getDouble('height');

// List<String>
List<String>? favorites = prefs.getStringList('favorites');
```

### 4. Supprimer des données

```dart
// Supprimer une clé spécifique
await prefs.remove('username');

// Supprimer toutes les données
await prefs.clear();
```

## Exemple complet d'authentification

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  // Sauvegarder le token après connexion
  static Future<void> saveToken(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
  }

  // Récupérer le token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Déconnexion
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  // Récupérer l'ID utilisateur
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    // Simulation d'une connexion
    String fakeToken = 'jwt_token_here';
    String userId = '123';

    // Sauvegarder dans SharedPreferences
    await AuthService.saveToken(fakeToken, userId);

    // Rediriger vers l'accueil
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userId;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _token = await AuthService.getToken();
    _userId = await AuthService.getUserId();
    setState(() {});
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenue !'),
            Text('User ID: $_userId'),
            Text('Token: ${_token?.substring(0, 10)}...'),
          ],
        ),
      ),
    );
  }
}
```

## Types de données supportés

SharedPreferences supporte les types suivants :

- `String`
- `int`
- `bool`
- `double`
- `List<String>`

Pour des données plus complexes, utilisez JSON :

```dart
// Sauvegarder un objet
Map<String, dynamic> user = {'name': 'John', 'age': 25};
String userJson = jsonEncode(user);
await prefs.setString('user', userJson);

// Récupérer un objet
String? userJson = prefs.getString('user');
if (userJson != null) {
  Map<String, dynamic> user = jsonDecode(userJson);
}
```

## Bonnes pratiques

### 1. Clés constantes

```dart
class PreferencesKeys {
  static const String userToken = 'user_token';
  static const String userId = 'user_id';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
}
```

### 2. Gestion d'erreurs

```dart
try {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('key', 'value');
} catch (e) {
  print('Erreur SharedPreferences: $e');
}
```

### 3. Initialisation

```dart
class AppPreferences {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    if (_prefs == null) {
      throw Exception('SharedPreferences not initialized');
    }
    return _prefs!;
  }
}

// Dans main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();
  runApp(MyApp());
}
```

### 4. Observers (écouteurs de changements)

SharedPreferences ne supporte pas nativement les listeners, mais vous pouvez créer un système personnalisé :

```dart
class PreferencesNotifier extends ChangeNotifier {
  final SharedPreferences _prefs;

  PreferencesNotifier(this._prefs);

  bool get isDarkMode => _prefs.getBool('dark_mode') ?? false;

  set isDarkMode(bool value) {
    _prefs.setBool('dark_mode', value);
    notifyListeners();
  }
}
```

## Limitations

- **Taille limitée** : Environ 10MB par application
- **Pas thread-safe** : Utilisez toujours dans le thread principal
- **Pas chiffré** : Ne stockez pas de données sensibles
- **Pas de listeners natifs** : Pour les changements en temps réel, utilisez un système personnalisé

## Alternatives

Pour des données plus complexes ou sensibles :

- **sqflite** : Base de données SQLite
- **hive** : Base de données NoSQL rapide
- **secure_storage** : Stockage chiffré pour données sensibles
- **firebase_database** : Base de données cloud

## Exemple dans notre application OM Pay

Dans notre application, SharedPreferences est utilisé pour :

1. **Stockage du token JWT** après connexion
2. **Vérification de l'état de connexion** au démarrage
3. **Suppression du token** lors de la déconnexion

```dart
// Sauvegarde du token
await prefs.setString('token', response.accessToken);

// Vérification
final token = prefs.getString('token');
if (token != null) {
  // Utilisateur connecté
}

// Déconnexion
await prefs.remove('token');
```

## Conclusion

SharedPreferences est parfait pour stocker des données simples et persistantes. Il est facile à utiliser et intégré nativement à Flutter. Pour des cas d'usage avancés, considérez des alternatives plus robustes.
# Guide de Connexion OM Pay

## Vue d'ensemble

Le système de connexion d'OM Pay permet aux utilisateurs de s'authentifier de manière sécurisée avec support pour la vérification à deux facteurs lors de la première connexion.

## Flux de connexion

### 1. Écran d'accueil (Splash Screen)
- Affiche le logo OM Pay pendant 500ms
- Vérifie automatiquement la présence d'un token JWT dans SharedPreferences
- Redirige vers :
  - `/home` si token valide
  - `/login` si pas de token

### 2. Écran de connexion
- Formulaire avec champs :
  - Identifiant (email ou téléphone)
  - Mot de passe
  - Checkbox "Première connexion - Code de vérification" (optionnel)
  - Champ code (affiché seulement si checkbox cochée)

### 3. Processus d'authentification

#### Connexion normale
```dart
POST /auth/login
{
  "identifier": "user@example.com",
  "password": "password123"
}
```

#### Connexion avec code (première connexion)
```dart
POST /auth/login
{
  "identifier": "user@example.com",
  "password": "password123",
  "code": "123456"
}
```

### 4. Réponse du serveur
```json
{
  "token_type": "Bearer",
  "expires_in": 3600,
  "access_token": "jwt_token_here",
  "refresh_token": "refresh_token_here"
}
```

## Gestion des erreurs

### Codes d'erreur courants

- **401 Unauthorized** : Identifiant ou mot de passe incorrect
- **400 Bad Request** : Données invalides
- **429 Too Many Requests** : Trop de tentatives
- **500 Internal Server Error** : Erreur serveur

### Messages d'erreur utilisateur

- "Identifiant ou mot de passe incorrect"
- "Code de vérification requis pour la première connexion"
- "Code de vérification invalide"
- "Connexion réseau impossible"

## Stockage du token

### SharedPreferences
```dart
// Sauvegarde
await prefs.setString('token', response.accessToken);

// Récupération
final token = prefs.getString('token');

// Suppression (déconnexion)
await prefs.remove('token');
```

### Sécurité
- Token stocké localement sur l'appareil
- Valide pour la session en cours
- Supprimé automatiquement lors de la déconnexion

## États de l'interface

### États de chargement
- Bouton "Se connecter" devient "Chargement..."
- Indicateur circulaire pendant l'appel API
- Interface désactivée pendant le traitement

### Validation des champs
- Identifiant requis
- Mot de passe requis (minimum 6 caractères)
- Code optionnel (si checkbox cochée)

### Gestion des erreurs
- Messages d'erreur sous chaque champ
- Focus automatique sur le champ en erreur
- Effacement des erreurs lors de la saisie

## Expérience utilisateur

### Bonnes pratiques
1. **Validation en temps réel** : Effacement des erreurs dès que l'utilisateur tape
2. **Feedback visuel** : Checkbox pour afficher/masquer le champ code
3. **Messages clairs** : Erreurs spécifiques selon le type d'échec
4. **Accessibilité** : Icônes et labels descriptifs

### Flow utilisateur

#### Première connexion
1. Coche "Première connexion - Code de vérification"
2. Saisit identifiant et mot de passe
3. Saisit le code reçu par SMS/email
4. Connexion réussie → redirection vers home

#### Connexion normale
1. Saisit identifiant et mot de passe
2. Connexion réussie → redirection vers home

#### Échec de connexion
1. Message d'erreur affiché
2. Possibilité de réessayer
3. Après 3 échecs : suggestion de récupération mot de passe

## Architecture technique

### Classes impliquées

#### LoginRequest
```dart
class LoginRequest {
  final String identifier;
  final String password;
  final String? code;

  LoginRequest({
    required this.identifier,
    required this.password,
    this.code,
  });

  Map<String, dynamic> toJson() => {
    'identifier': identifier,
    'password': password,
    if (code != null) 'code': code,
  };
}
```

#### AuthService
```dart
class AuthService {
  final ApiService api;

  Future<LoginResponse> login(LoginRequest request) async {
    final json = await api.post('/auth/login', request.toJson());
    return LoginResponse.fromJson(json);
  }
}
```

#### LoginScreen State
```dart
class _LoginScreenState extends State<LoginScreen> {
  // Contrôleurs et états
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  bool _showCodeField = false;
  bool _isLoading = false;

  // Gestion des erreurs
  String? _identifierError;
  String? _passwordError;
  String? _codeError;
}
```

## Tests et validation

### Scénarios de test
- Connexion réussie avec/sans code
- Échec avec mauvais identifiant/mot de passe
- Code invalide
- Connexion réseau impossible
- Token expiré

### Validation des données
- Format email valide
- Mot de passe non vide
- Code numérique (si fourni)

## Sécurité

### Mesures implémentées
- Hashage du mot de passe côté serveur
- Token JWT avec expiration
- Validation côté client et serveur
- Protection contre les attaques par force brute

### Recommandations
- Utiliser HTTPS en production
- Implémenter un système de refresh token
- Ajouter une limite de tentatives de connexion
- Journaliser les tentatives de connexion suspectes

## Maintenance et évolution

### Améliorations futures
- Support pour la biométrie (Touch ID / Face ID)
- Connexion sociale (Google, Facebook)
- Magic link par email
- Authentification à deux facteurs obligatoire

### Monitoring
- Taux de succès des connexions
- Temps de réponse des appels API
- Fréquence des erreurs de connexion
- Utilisation du champ code optionnel
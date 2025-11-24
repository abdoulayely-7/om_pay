import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<Map<String, dynamic>> post(String endpoint, Map data) async {
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> postWithToken(
    String endpoint,
    Map data,
    String token,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(String endpoint, String? token) async {
    final response = await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    // Gestion spéciale pour les redirections Laravel (même pour les codes 200)
    if (response.body.trim().startsWith('<!DOCTYPE html>') ||
        response.body.trim().startsWith('<html>')) {
      // Vérifier si c'est une page de redirection Laravel
      if (response.body.contains('Redirecting to')) {
        final redirectMatch = RegExp(
          r'Redirecting to <a href="([^"]+)">([^<]+)</a>',
        ).firstMatch(response.body);
        if (redirectMatch != null) {
          throw Exception(
            'HTTP ${response.statusCode}: Redirection détectée vers ${redirectMatch.group(1)} - Problème d\'authentification ou d\'autorisation Laravel',
          );
        }
      }

      // Chercher des messages d'erreur dans le HTML Laravel
      final errorPatterns = [
        RegExp(r'<h1[^>]*>(.*?)</h1>', caseSensitive: false),
        RegExp(
          r'<div[^>]*class="[^"]*error[^"]*"[^>]*>(.*?)</div>',
          caseSensitive: false,
          dotAll: true,
        ),
        RegExp(r'<p[^>]*>(.*?)</p>', caseSensitive: false, dotAll: true),
        RegExp(r'<title>(.*?)</title>', caseSensitive: false),
      ];

      String extractedMessage = '';
      for (final pattern in errorPatterns) {
        final match = pattern.firstMatch(response.body);
        if (match != null && match.group(1) != null) {
          final cleanText = match
              .group(1)!
              .replaceAll(RegExp(r'<[^>]*>'), '')
              .trim();
          if (cleanText.isNotEmpty &&
              !cleanText.contains('DOCTYPE') &&
              !cleanText.contains('html') &&
              !cleanText.contains('Redirecting')) {
            extractedMessage = cleanText;
            break;
          }
        }
      }

      if (extractedMessage.isEmpty) {
        // Essayer d'extraire tout texte significatif du HTML
        final bodyMatch = RegExp(
          r'<body[^>]*>(.*?)</body>',
          caseSensitive: false,
          dotAll: true,
        ).firstMatch(response.body);
        if (bodyMatch != null && bodyMatch.group(1) != null) {
          final bodyText = bodyMatch
              .group(1)!
              .replaceAll(RegExp(r'<[^>]*>'), '')
              .trim();
          if (bodyText.isNotEmpty && bodyText.length < 500) {
            extractedMessage = bodyText;
          }
        }
      }

      if (extractedMessage.isEmpty) {
        extractedMessage =
            'Erreur serveur Laravel - Page HTML reçue au lieu de JSON. Vérifiez les logs Laravel pour plus de détails.';
      }

      throw Exception('HTTP ${response.statusCode}: $extractedMessage');
    }

    if (response.statusCode >= 400) {
      // Essayer de parser comme JSON d'abord
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map<String, dynamic>) {
          if (errorData.containsKey('message')) {
            throw Exception(
              'HTTP ${response.statusCode}: ${errorData['message']}',
            );
          }
          if (errorData.containsKey('error')) {
            throw Exception(
              'HTTP ${response.statusCode}: ${errorData['error']}',
            );
          }
          if (errorData.containsKey('errors') && errorData['errors'] is Map) {
            final errors = errorData['errors'] as Map<String, dynamic>;
            final errorMessages = errors.values
                .expand((list) => list is List ? list : [list])
                .join(', ');
            throw Exception('HTTP ${response.statusCode}: $errorMessages');
          }
        }
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      } catch (e) {
        if (e.toString().startsWith('Exception: HTTP')) {
          rethrow;
        }
        throw Exception(
          'HTTP ${response.statusCode}: Erreur de l\'API - ${response.body}',
        );
      }
    }

    // Pour les réponses réussies, parser le JSON
    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception(
        'Erreur de parsing JSON de la réponse réussie: ${response.body}',
      );
    }
  }
}

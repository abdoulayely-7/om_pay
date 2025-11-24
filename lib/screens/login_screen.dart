import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/carousel_image.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../utils/error_messages.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  bool _showCodeField = false;
  String? _identifierError;
  String? _passwordError;
  String? _codeError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _identifierError = null;
      _passwordError = null;
      _codeError = null;
    });
  }

  Future<void> _login() async {
    _clearErrors();

    // Validation
    bool hasError = false;

    if (_identifierController.text.trim().isEmpty) {
      setState(() => _identifierError = 'Identifiant requis');
      hasError = true;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = ErrorMessages.motDePasseRequis);
      hasError = true;
    }

    if (hasError) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _identifierController.text.trim(),
      _passwordController.text,
      code: _showCodeField ? _codeController.text : null,
    );

    if (success) {
      if (mounted) {
        context.go('/home');
      }
    } else {
      String errorMessage = authProvider.error ?? 'Erreur de connexion';

      if (errorMessage.contains('401') || errorMessage.contains('incorrect')) {
        setState(() => _passwordError = 'Identifiant ou mot de passe incorrect');
      } else {
        setState(() => _passwordError = errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Carousel d'images en haut
              const CarouselImage(),

              // Formulaire de connexion
              Padding(
                padding: const EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      Text(
                        'Bienvenue sur OM Pay!',
                        style: AppTextStyles.header2,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Entrez vos identifiants pour vous connecter',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Identifiant
                      CustomTextField(
                        hintText: 'Email ou téléphone',
                        controller: _identifierController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.person, color: AppColors.primaryOrange),
                        errorText: _identifierError,
                        onChanged: (value) {
                          if (_identifierError != null) {
                            setState(() => _identifierError = null);
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      // Mot de passe
                      CustomTextField(
                        hintText: 'Mot de passe',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: const Icon(Icons.lock, color: AppColors.primaryOrange),
                        errorText: _passwordError,
                        onChanged: (value) {
                          if (_passwordError != null) {
                            setState(() => _passwordError = null);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Checkbox pour code de vérification
                      CheckboxListTile(
                        title: Text(
                          'Première connexion - Code de vérification',
                          style: AppTextStyles.bodyMedium,
                        ),
                        value: _showCodeField,
                        onChanged: (value) {
                          setState(() => _showCodeField = value ?? false);
                        },
                        activeColor: AppColors.primaryOrange,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      // Champ code (optionnel)
                      if (_showCodeField) ...[
                        const SizedBox(height: 8),
                        CustomTextField(
                          hintText: 'Code de vérification',
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.security, color: AppColors.primaryOrange),
                          errorText: _codeError,
                          onChanged: (value) {
                            if (_codeError != null) {
                              setState(() => _codeError = null);
                            }
                          },
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Mot de passe oublié
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password
                          },
                          child: Text(
                            'Mot de passe oublié ?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Bouton connexion
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) => CustomButton(
                          text: 'Se connecter',
                          onPressed: _login,
                          isLoading: authProvider.isLoading,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Inscription
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Pas encore de compte ? ',
                            style: AppTextStyles.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: Text(
                              'S\'inscrire',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
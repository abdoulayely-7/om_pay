import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../api/api_service.dart';
import '../config/config.dart';
import '../services/auth/auth_service.dart';
import '../dto/request/register_request.dart';
import '../utils/error_messages.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ApiService _api = ApiService(Config.apiBaseUrl);
  late final AuthService _authService;
  bool _isLoading = false;
  String? _nomError;
  String? _prenomError;
  String? _telephoneError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(_api);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _nomError = null;
      _prenomError = null;
      _telephoneError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
  }

  Future<void> _register() async {
    _clearErrors();

    // Validation
    bool hasError = false;

    if (_nomController.text.trim().isEmpty) {
      setState(() => _nomError = ErrorMessages.nomRequis);
      hasError = true;
    }

    if (_prenomController.text.trim().isEmpty) {
      setState(() => _prenomError = ErrorMessages.prenomRequis);
      hasError = true;
    }

    if (_telephoneController.text.trim().isEmpty) {
      setState(() => _telephoneError = ErrorMessages.telephoneRequis);
      hasError = true;
    } else if (_telephoneController.text.trim().length < 9) {
      setState(() => _telephoneError = ErrorMessages.telephoneInvalide);
      hasError = true;
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = ErrorMessages.emailRequis);
      hasError = true;
    } else if (!_emailController.text.contains('@')) {
      setState(() => _emailError = ErrorMessages.emailInvalide);
      hasError = true;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = ErrorMessages.motDePasseRequis);
      hasError = true;
    } else if (_passwordController.text.length < 6) {
      setState(() => _passwordError = ErrorMessages.motDePasseCourt);
      hasError = true;
    }

    if (_confirmPasswordController.text.isEmpty) {
      setState(() => _confirmPasswordError = 'Veuillez confirmer votre mot de passe');
      hasError = true;
    } else if (_confirmPasswordController.text != _passwordController.text) {
      setState(() => _confirmPasswordError = 'Les mots de passe ne correspondent pas');
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      final name = '${_prenomController.text.trim()} ${_nomController.text.trim()}';
      final request = RegisterRequest(
        name: name,
        email: _emailController.text.trim(),
        telephone: _telephoneController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      await _authService.register(request);

      setState(() => _isLoading = false);

      if (mounted) {
        // After successful registration, go to login
        context.go('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription réussie ! Veuillez vous connecter.')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      String errorMessage = ErrorMessages.parseBackendError(e);

      // Map errors to fields
      if (errorMessage.contains('nom') && !errorMessage.contains('prénom')) {
        setState(() => _nomError = errorMessage);
      } else if (errorMessage.contains('prénom')) {
        setState(() => _prenomError = errorMessage);
      } else if (errorMessage.contains('téléphone') || errorMessage.contains('existe déjà')) {
        setState(() => _telephoneError = errorMessage);
      } else if (errorMessage.contains('email') || errorMessage.contains('e-mail')) {
        setState(() => _emailError = errorMessage);
      } else if (errorMessage.contains('mot de passe')) {
        setState(() => _passwordError = errorMessage);
      } else {
        setState(() => _confirmPasswordError = errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Inscription', style: AppTextStyles.header1),
                const SizedBox(height: 8),
                Text(
                  'Créez votre compte OM Pay',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Nom
                CustomTextField(
                  hintText: 'Nom',
                  controller: _nomController,
                  prefixIcon: const Icon(Icons.person, color: AppColors.primaryOrange),
                  errorText: _nomError,
                  onChanged: (value) {
                    if (_nomError != null) setState(() => _nomError = null);
                  },
                ),
                const SizedBox(height: 16),

                // Prénom
                CustomTextField(
                  hintText: 'Prénom',
                  controller: _prenomController,
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryOrange),
                  errorText: _prenomError,
                  onChanged: (value) {
                    if (_prenomError != null) setState(() => _prenomError = null);
                  },
                ),
                const SizedBox(height: 16),

                // Téléphone
                CustomTextField(
                  hintText: 'Numéro de téléphone',
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone, color: AppColors.primaryOrange),
                  errorText: _telephoneError,
                  onChanged: (value) {
                    if (_telephoneError != null) setState(() => _telephoneError = null);
                  },
                ),
                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  hintText: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email, color: AppColors.primaryOrange),
                  errorText: _emailError,
                  onChanged: (value) {
                    if (_emailError != null) setState(() => _emailError = null);
                  },
                ),
                const SizedBox(height: 16),

                // Mot de passe
                CustomTextField(
                  hintText: 'Mot de passe',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock, color: AppColors.primaryOrange),
                  errorText: _passwordError,
                  onChanged: (value) {
                    if (_passwordError != null) setState(() => _passwordError = null);
                  },
                ),
                const SizedBox(height: 16),

                // Confirmer mot de passe
                CustomTextField(
                  hintText: 'Confirmer le mot de passe',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryOrange),
                  errorText: _confirmPasswordError,
                  onChanged: (value) {
                    if (_confirmPasswordError != null) setState(() => _confirmPasswordError = null);
                  },
                ),
                const SizedBox(height: 32),

                // Bouton inscription
                CustomButton(
                  text: 'S\'inscrire',
                  onPressed: _register,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),

                // Connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Déjà un compte ? ', style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Se connecter',
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
      ),
    );
  }
}
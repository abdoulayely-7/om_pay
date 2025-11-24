import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_type_toggle.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/transaction_card.dart';
import '../widgets/custom_snackbar.dart';
import '../api/api_service.dart';
import '../config/config.dart';
import '../services/client_service.dart';
import '../dto/response/dashboard_response.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TransactionType _selectedType = TransactionType.transfer;
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isDarkMode = true;
  bool _isScannerEnabled = true;
  String _selectedLanguage = 'Français';

  // API services
  final ApiService _api = ApiService(Config.apiBaseUrl);
  late final ClientService _clientService;

  // Real data from API
  double _balance = 0;
  String _userName = '';
  String _userPhone = '';
  List<TransactionResource> _transactions = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _clientService = ClientService(_api);
    _loadDashboard();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _loadDashboard() async {
    try {
      final token = await _getToken();
      if (token == null) {
        context.go('/login');
        return;
      }

      final dashboardResponse = await _clientService.getDashboard(token);
      final dashboard = dashboardResponse.data!;

      setState(() {
        _balance = dashboard.solde;
        _userName = dashboard.user.name;
        _userPhone = dashboard.user.telephone;
        _transactions = dashboard.transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        CustomSnackbar.showError(
          context,
          'Erreur lors du chargement des données',
        );
      }
    }
  }

  Future<void> _refreshTransactions() async {
    try {
      final token = await _getToken();
      if (token == null) {
        context.go('/login');
        return;
      }

      final transactions = await _clientService.getTransactions(token);

      setState(() {
        _transactions = transactions as List<TransactionResource>;
      });
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          'Erreur lors du rafraîchissement des transactions',
        );
      }
    }
  }


  IconData _getTransactionIcon(String type) {
    switch (type.toUpperCase()) {
      case 'TRANSFERT':
        return Icons.send_outlined;
      case 'DEPOT':
        return Icons.account_balance_wallet_outlined;
      case 'RETRAIT':
        return Icons.money_outlined;
      case 'PAIEMENT':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  String _getTransactionTitle(String type) {
    switch (type.toUpperCase()) {
      case 'TRANSFERT':
        return 'Transfert d\'argent';
      case 'DEPOT':
        return 'Dépôt d\'argent';
      case 'RETRAIT':
        return 'Retrait d\'argent';
      case 'PAIEMENT':
        return 'Paiement marchand';
      default:
        return 'Transaction';
    }
  }

  bool _isTransactionPositive(TransactionResource transaction) {
    // Assuming DEPOT is positive, others are negative
    return transaction.type.toUpperCase() == 'DEPOT';
  }

  String _formatTransactionDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _handleTransaction() async {
    // Mock transaction handling for design
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isProcessing = false);

    if (mounted) {
      CustomSnackbar.showSuccess(
        context,
        _selectedType == TransactionType.pay
            ? 'Paiement effectué avec succès'
            : 'Transfert effectué avec succès',
      );
    }

    _numberController.clear();
    _amountController.clear();
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Mon QR Code', style: AppTextStyles.header3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.qr_code, size: 180),
            ),
            const SizedBox(height: 16),
            Text(
              _userPhone,
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        userName: _userName,
        userPhone: _userPhone,
        isDarkMode: _isDarkMode,
        isScannerEnabled: _isScannerEnabled,
        selectedLanguage: _selectedLanguage,
        onThemeToggle: () => setState(() => _isDarkMode = !_isDarkMode),
        onScannerToggle: () => setState(() => _isScannerEnabled = !_isScannerEnabled),
        onLanguageChanged: (lang) => setState(() => _selectedLanguage = lang),
        onLogout: _logout,
      ),
      body: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance Card
            BalanceCard(
              balance: _balance,
              userName: _userName,
              onQrCodeTap: _showQRCode,
              onMenuTap: () => Scaffold.of(context).openDrawer(),
            ),

            // Transaction Form avec image rainbow en arrière-plan
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white24,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                    spreadRadius: 2,
                  )
                ]
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -10,
                    bottom: -10,
                    right: 0,
                    left: 0,
                    child: Opacity(
                      opacity: 0.8,
                      child: Image.asset(
                        'assets/images/rainbow_bg.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Contenu du formulaire EN SECOND (devant l'image)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Toggle Payer/Transférer
                        TransactionTypeToggle(
                          selectedType: _selectedType,
                          onChanged: (type) => setState(() => _selectedType = type),
                        ),

                        const SizedBox(height: 8),

                        // Numéro/Code marchand
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: CustomTextField(
                              hintText: _selectedType == TransactionType.pay
                                  ? 'Saisir le numéro/code march...'
                                  : 'Saisir le numéro',
                              controller: _numberController,
                              keyboardType: TextInputType.phone,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.person_add, color: AppColors.primaryOrange, size: 22),
                                onPressed: () {
                                  // TODO: Select from contacts
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Montant
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: CustomTextField(
                              hintText: 'Saisir le montant',
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Bouton Valider
                        CustomButton(
                          text: 'Valider',
                          onPressed: _handleTransaction,
                          isLoading: _isProcessing,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Text(
                'Pour toute autre opération',
                style: AppTextStyles.bodyMedium,
              ),
            ),

            // Max it Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Max it',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Accéder à Max it',
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),

            // Historique Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Historique', style: AppTextStyles.header3),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.primaryOrange),
                    onPressed: _refreshTransactions,
                  ),
                ],
              ),
            ),

            // Scrollable Transactions List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryOrange),
                    )
                  : _transactions.isEmpty
                      ? Center(
                          child: Text(
                            'Aucune transaction',
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _transactions[index];
                            return TransactionCard(
                              icon: _getTransactionIcon(transaction.type),
                              title: _getTransactionTitle(transaction.type),
                              subtitle: transaction.reference,
                              amount: transaction.montant.toStringAsFixed(0),
                              date: _formatTransactionDate(transaction.dateTransaction),
                              isPositive: _isTransactionPositive(transaction),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
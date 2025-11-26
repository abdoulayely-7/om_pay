import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_type_toggle.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/transaction_card.dart';
import '../widgets/custom_snackbar.dart';
import '../providers/auth_provider.dart';
import '../providers/balance_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../dto/response/transaction_response.dart' as tr;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isScannerEnabled = true;
  String _selectedLanguage = 'Français';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Écouter les changements d'authentification
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isInitialized && authProvider.isLoggedIn) {
      final balanceProvider = Provider.of<BalanceProvider>(
        context,
        listen: false,
      );
      if (balanceProvider.transactions.isEmpty && !balanceProvider.isLoading) {
        _loadDashboard();
      }
    }
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Attendre que l'auth soit initialisé
    while (!authProvider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // print('Auth initialized: ${authProvider.isInitialized}');
    // print('Token: ${authProvider.token}');
    // print('Is logged in: ${authProvider.isLoggedIn}');

    if (authProvider.isLoggedIn) {
      // print('Loading dashboard...');
      await _loadDashboard();
    } else {
      // print('Not logged in, navigating to login...');
      // Navigation différée pour éviter l'erreur de build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // print('Executing navigation to /login');
          context.go('/login');
        }
      });
    }
  }

  Future<void> _loadDashboard() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final balanceProvider = Provider.of<BalanceProvider>(
      context,
      listen: false,
    );

    if (authProvider.token != null) {
      await balanceProvider.loadDashboard(authProvider.token!);
    }
  }

  void _showQRCode() {
    final balanceProvider = Provider.of<BalanceProvider>(
      context,
      listen: false,
    );
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
            Text(balanceProvider.userPhone, style: AppTextStyles.bodyLarge),
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

  Future<void> _handleTransaction() async {
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final balanceProvider = Provider.of<BalanceProvider>(
      context,
      listen: false,
    );

    final number = _numberController.text.trim();
    final amountText = _amountController.text.trim();

    if (number.isEmpty) {
      CustomSnackbar.showError(
        context,
        transactionProvider.selectedType == TransactionType.pay
            ? 'Le code marchand est requis'
            : 'Le numéro destinataire est requis',
      );
      return;
    }

    if (amountText.isEmpty) {
      CustomSnackbar.showError(context, 'Le montant est requis');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      CustomSnackbar.showError(context, 'Montant invalide');
      return;
    }

    if (amount > balanceProvider.balance) {
      CustomSnackbar.showError(context, 'Solde insuffisant');
      return;
    }

    if (transactionProvider.selectedType == TransactionType.transfer) {
      if (number == balanceProvider.userPhone) {
        CustomSnackbar.showError(
          context,
          'Vous ne pouvez pas transférer vers votre propre numéro',
        );
        return;
      }
    }

    bool success = false;
    if (transactionProvider.selectedType == TransactionType.transfer) {
      success = await transactionProvider.transfer(
        token: authProvider.token!,
        recipientPhone: number,
        amount: amount,
      );
    } else {
      success = await transactionProvider.pay(
        token: authProvider.token!,
        merchantCode: number,
        amount: amount,
      );
    }

    if (success) {
      CustomSnackbar.showSuccess(
        context,
        transactionProvider.selectedType == TransactionType.pay
            ? 'Paiement effectué avec succès'
            : 'Transfert effectué avec succès',
      );
      _numberController.clear();
      _amountController.clear();

      // Recharger les données
      await balanceProvider.loadDashboard(authProvider.token!);
    } else {
      // Afficher l'erreur du provider
      CustomSnackbar.showError(
        context,
        transactionProvider.error ?? 'Erreur lors de la transaction',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<AuthProvider, BalanceProvider, TransactionProvider, ThemeProvider>(
      builder:
          (context, authProvider, balanceProvider, transactionProvider, themeProvider, child) {
            // Afficher un écran de chargement pendant l'initialisation de l'auth
            if (!authProvider.isInitialized) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return Scaffold(
              drawer: CustomDrawer(
                userName: balanceProvider.userName,
                userPhone: balanceProvider.userPhone,
                isDarkMode: themeProvider.isDarkMode,
                isScannerEnabled: _isScannerEnabled,
                selectedLanguage: _selectedLanguage,
                onThemeToggle: () => themeProvider.toggleTheme(),
                onScannerToggle: () =>
                    setState(() => _isScannerEnabled = !_isScannerEnabled),
                onLanguageChanged: (lang) =>
                    setState(() => _selectedLanguage = lang),
                onLogout: () {
                  authProvider.logout();
                  balanceProvider.reset();
                  context.go('/');
                },
              ),
              body: Builder(
                builder: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Balance Card
                    BalanceCard(
                      balance: balanceProvider.balance,
                      userName: balanceProvider.userName,
                      onQrCodeTap: _showQRCode,
                      onMenuTap: () => Scaffold.of(context).openDrawer(),
                    ),

                    // Transaction Form
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 13,
                      ),
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
                          ),
                        ],
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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Toggle Payer/Transférer
                                TransactionTypeToggle(
                                  selectedType:
                                      transactionProvider.selectedType ??
                                      TransactionType.transfer,
                                  onChanged: (type) => transactionProvider
                                      .setTransactionType(type),
                                ),

                                const SizedBox(height: 8),

                                // Numéro/Code marchand
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: CustomTextField(
                                      hintText:
                                          transactionProvider.selectedType ==
                                              TransactionType.pay
                                          ? 'Saisir le code marchand'
                                          : 'Saisir le numéro',
                                      controller: _numberController,
                                      keyboardType: transactionProvider.selectedType ==
                                              TransactionType.pay
                                          ? TextInputType.text  // Alphanumérique pour code marchand
                                          : TextInputType.phone, // Numérique pour téléphone
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Montant
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
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
                                  isLoading:
                                      transactionProvider.isProcessing ?? false,
                                ),
                              ],
                            ),
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
                            icon: const Icon(
                              Icons.refresh,
                              color: AppColors.primaryOrange,
                            ),
                            onPressed: () async {
                              if (authProvider.token != null) {
                                await balanceProvider.refreshTransactions(
                                  authProvider.token!,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // Transactions List
                    Expanded(
                      child: balanceProvider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryOrange,
                              ),
                            )
                          : balanceProvider.transactions.isEmpty
                          ? Center(
                              child: Text(
                                'Aucune transaction',
                                style: AppTextStyles.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 20),
                              itemCount: balanceProvider.transactions.length,
                              itemBuilder: (context, index) {
                                final transaction =
                                    balanceProvider.transactions[index];
                                final isPositive =
                                    transaction.type.toUpperCase() == 'DEPOT';

                                return TransactionCard(
                                  icon: _getTransactionIcon(transaction.type),
                                  title: _getTransactionTitle(transaction.type),
                                  subtitle: transaction.reference,
                                  amount: transaction.montant.toStringAsFixed(
                                    0,
                                  ),
                                  date: _formatTransactionDate(
                                    transaction.dateTransaction,
                                  ),
                                  isPositive: isPositive,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
    );
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

  String _formatTransactionDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}

import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../config/config.dart';
import '../services/client_service.dart';
import '../dto/response/dashboard_response.dart';
import '../dto/response/dashboard_response.dart';
import '../dto/response/transaction_response.dart' as tr;

class BalanceProvider extends ChangeNotifier {
  final ApiService _api = ApiService(Config.apiBaseUrl);
  late final ClientService _clientService;

  // Data
  double _balance = 0;
  String _userName = '';
  String _userPhone = '';
  List<tr.TransactionResource> _transactions = [];

  // States
  bool _isLoading = true;
  bool _isRefreshingTransactions = false;
  String? _error;

  BalanceProvider() {
    _clientService = ClientService(_api);
  }

  // Getters
  double get balance => _balance;
  String get userName => _userName;
  String get userPhone => _userPhone;
  List<tr.TransactionResource> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isRefreshingTransactions => _isRefreshingTransactions;
  String? get error => _error;

  // Load dashboard data (balance + user info + transactions)
  Future<void> loadDashboard(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dashboardResponse = await _clientService.getDashboard(token);
      final dashboard = dashboardResponse.data!;

      _balance = dashboard.solde;
      _userName = dashboard.user.name;
      _userPhone = dashboard.user.telephone;

      // Charger les transactions séparément
      try {
        _transactions = await _clientService.getTransactions(token);
      } catch (e) {
        print('Erreur lors du chargement des transactions: $e');
        _transactions = [];
      }

      print('Dashboard loaded: balance=${_balance}, user=${_userName}, transactions=${_transactions.length}');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading dashboard: $e');
      _isLoading = false;
      _error = 'Erreur lors du chargement des données';
      notifyListeners();
    }
  }

  // Refresh only transactions
  Future<void> refreshTransactions(String token) async {
    _isRefreshingTransactions = true;
    _error = null;
    notifyListeners();

    try {
      final transactions = await _clientService.getTransactions(token);
      _transactions = transactions;
      _isRefreshingTransactions = false;
      notifyListeners();
    } catch (e) {
      _isRefreshingTransactions = false;
      _error = 'Erreur lors du rafraîchissement des transactions';
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset data (for logout)
  void reset() {
    _balance = 0;
    _userName = '';
    _userPhone = '';
    _transactions = [];
    _isLoading = true;
    _error = null;
    notifyListeners();
  }
}
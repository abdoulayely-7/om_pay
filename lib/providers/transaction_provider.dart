import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../config/config.dart';
import '../services/client_service.dart';
import '../dto/request/transfer_request.dart';
import '../dto/request/payment_request.dart';
import '../widgets/transaction_type_toggle.dart';

class TransactionProvider extends ChangeNotifier {
  final ApiService _api = ApiService(Config.apiBaseUrl);
  late final ClientService _clientService;

  TransactionType _selectedType = TransactionType.transfer;
  bool _isProcessing = false;
  String? _error;

  TransactionProvider() {
    _clientService = ClientService(_api);
  }

  // Getters
  TransactionType get selectedType => _selectedType;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  // Set transaction type
  void setTransactionType(TransactionType type) {
    _selectedType = type;
    notifyListeners();
  }

  // Transfer money
  Future<bool> transfer({
    required String token,
    required String recipientPhone,
    required double amount,
  }) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final request = TransferRequest(
        telephoneDestinataire: recipientPhone,
        montant: amount,
      );

      await _clientService.effectuerTransfert(token, request);

      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isProcessing = false;
      String errorMessage = e
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('HTTP 500: ', '')
          .replaceAll('HTTP 400: ', '')
          .replaceAll('HTTP 422: ', '')
          .replaceAll('ClientException: ', '') // Pour les erreurs réseau
          .replaceAll(
            'Failed to fetch',
            'Erreur de connexion réseau',
          ) // Message user-friendly
          .trim();
      _error = errorMessage;
      notifyListeners();
      return false;
    }
  }

  // Make payment
  Future<bool> pay({
    required String token,
    required String merchantCode,
    required double amount,
  }) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final request = PaymentRequest(
        codeMarchand: merchantCode,
        montant: amount,
      );

      await _clientService.effectuerPaiement(token, request);

      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isProcessing = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
